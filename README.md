# AI SEO Assistant

A web-based SEO assistant that:
- Crawls websites (with JavaScript rendering using Playwright)
- Analyzes SEO elements: title, meta tags, headings, alt text
- Generates smart suggestions using AI (OpenAI)

---

## Setup Instructions

### 1. Clone or download the project
```
git clone <your-repo-url>  # or download the ZIP from this assistant
cd ai_seo_assistant
```

### 2. Create a virtual environment (recommended)
```
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies
```
pip install -r requirements.txt
python -m playwright install
```

### 4. Run the app
```
python app.py
```

Go to `http://localhost:5000` in your browser.

---

## Optional
- You can connect OpenAI API later for meta tag generation
- Add export to PDF/HTML reports

---

## Stack
- Python + Flask
- Playwright (Chromium headless browser)
- BeautifulSoup
- OpenAI (optional)