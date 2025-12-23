# app/services/npdb/xml_builder.rb
module Npdb
  class XmlBuilder
    def initialize(provider, npdb)
      @provider = provider
      @npdb     = npdb
    end

    def build
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <NPDBQueryRequest>
          <Practitioner>
            <FirstName>#{@provider.first_name}</FirstName>
            <MiddleName>#{@provider.middle_name}</MiddleName>
            <LastName>#{@provider.last_name}</LastName>
            <PractitionerType>#{@npdb.practitioner_type}</PractitionerType>
            <IdentificationNumbers>
              #{ids}
            </IdentificationNumbers>
          </Practitioner>
        </NPDBQueryRequest>
      XML
    end

    def ids
      [
        @npdb.individual_identification_number_1,
        @npdb.individual_identification_number_2,
        @npdb.individual_identification_number_3,
        @npdb.individual_identification_number_4
      ].compact.map { |i| "<ID>#{i}</ID>" }.join
    end
  end
end
