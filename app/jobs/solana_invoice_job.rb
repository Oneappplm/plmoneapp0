require 'net/http'
require 'json'

class SolanaInvoiceJob < ApplicationJob
  queue_as :default

  SQUAD_WALLET = "JDwPdnzhKZYpqs1ygCPaEuVCsyuS5Z7psWv3ASKeEy6T"
  SOLANA_RPC_URL = "https://api.mainnet-beta.solana.com"

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    Rails.logger.info "🔧 Loaded invoice #{invoice.id} with status: #{invoice.status}"

    return unless invoice.status == "unpaid"

    Rails.logger.info "🔍 Searching Solana for memo: #{invoice.payment_memo}"

    expected_memo = invoice.payment_memo
    matching_tx = find_transaction_by_memo(SQUAD_WALLET, expected_memo)

    if matching_tx
      signature = matching_tx.dig("transaction", "signatures", 0)
      amount = invoice.total

      invoice.update!(status: "paid")
      invoice.create_payment!(
        solana_signature: signature,
        payment_method: "solana",
        amount: amount
      )

      TransactionLog.create!(
        invoice_id: invoice.id,
        solana_tx: signature,
        status: "confirmed",
        memo: expected_memo,
        amount: amount,
        confirmed_at: Time.current
      )

      Rails.logger.info "✅ invoice #{invoice.id} marked as paid via Solana (#{signature})"
    else
      Rails.logger.info "🔍 No matching Solana transaction found for invoice #{invoice.id}"
    end
  end


  private

  def find_transaction_by_memo(wallet, expected_memo, limit: 20, max_batches: 20)
    headers = { 'Content-Type' => 'application/json' }
    uri = URI(SOLANA_RPC_URL)
    before = nil

    max_batches.times do
      body = {
        jsonrpc: "2.0",
        id: 1,
        method: "getSignaturesForAddress",
        params: [
          wallet,
          { "limit": limit, "before": before }.compact
        ]
      }

      res = Net::HTTP.post(uri, body.to_json, headers)
      signature_list = JSON.parse(res.body)["result"]
      break if signature_list.blank?

      signature_list.each do |sig_info|
        tx = fetch_transaction(sig_info["signature"])
        next unless tx
        memo = extract_memo_from_tx(tx)
        if memo == expected_memo
          return tx
        end
      end

      before = signature_list.last["signature"]
    end

    nil
  rescue StandardError => e
    Rails.logger.error "❌ Error while searching for transaction by memo: #{e.message}"
    nil
  end

  def fetch_transaction(signature)
    headers = { 'Content-Type' => 'application/json' }
    uri = URI(SOLANA_RPC_URL)

    body = {
      jsonrpc: "2.0",
      id: 1,
      method: "getTransaction",
      params: [
        signature,
        { encoding: "json", commitment: "finalized" }
      ]
    }

    res = Net::HTTP.post(uri, body.to_json, headers)
    JSON.parse(res.body)["result"]
  rescue => e
    Rails.logger.warn "⚠️ Could not fetch transaction for #{signature}: #{e.message}"
    nil
  end

  def sol_amount(tx)
    pre = tx.dig("meta", "preBalances")
    post = tx.dig("meta", "postBalances")
    keys = tx.dig("transaction", "message", "accountKeys")
    return 0 unless pre && post && keys

    index = keys.index(SQUAD_WALLET)
    return 0 unless index

    sol = (post[index] - pre[index]) / 1_000_000_000.0
    sol.round(5)
  end

  def extract_memo_from_tx(tx)
    log_messages = tx.dig("meta", "logMessages")
    memo_log = log_messages&.find { |msg| msg.include?("Program log: Memo") }
    memo_log&.match(/Memo \(len \d+\): "(.*)"/)&.captures&.first
  end
end
