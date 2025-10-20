''' Generate docker file in different programing language using
google gemini llm model.
'''
import google.generativeai as genai
import os

# Set your api key here
os.environ['GOOGLE_API_KEY'] = 'xxxxxxxxxxxxxxxxxxxxxx'

# Configure the gemini model
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))
model = genai.GenerativeModel('gemini-2.5-flash')

PROMT = """
Generate an ideal Dockerfile for {language} with best practices. Just share the dockerfile without any explanation between two lines to make copying dockerfile easy.
Include:
- Base image
- Installing dependencies
- Setting working directory
- Adding source code
- Running the application
"""

def generate_dockerfile(language):
    response = model.generate_content(PROMT.format(language))
    return response.text

if __name__ == "__main__":
    language = input("Enter the language: ")
    dockerfile = generate_dockerfile(language)
    print("\nGenerated dockerfile:\n")
    print(dockerfile)
