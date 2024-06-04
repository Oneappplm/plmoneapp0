import PyPDF2
import json
import sys

def extract_pdf_fields(file_path):
    with open(file_path, "rb") as pdf_document:
        pdf_reader = PyPDF2.PdfReader(pdf_document)

        if "/AcroForm" in pdf_reader.trailer["/Root"]:
            form = pdf_reader.trailer["/Root"]["/AcroForm"]
            fields = form.get("/Fields", [])
        else:
            fields = []

        field_data = {}
        for field in fields:
            field_object = field.get_object()
            field_name = field_object.get("/T")
            field_value = field_object.get("/V")
            field_data[field_name] = field_value

        return json.dumps(field_data)

if __name__ == "__main__":
    file_path = sys.argv[1]
    print(extract_pdf_fields(file_path))
