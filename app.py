
from flask import Flask, render_template, request
import asyncio
from seo_analyzer import SEOAnalyzer

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/analyze', methods=['POST'])
def analyze():
    url = request.form['url']
    depth = int(request.form.get('depth', 2))

    analyzer = SEOAnalyzer(url, max_depth=depth)
    results = asyncio.run(analyzer.crawl())

    return render_template('results.html', results=results, base_url=url)

if __name__ == '__main__':
    app.run(debug=True)
