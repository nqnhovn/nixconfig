import urllib.request
import urllib.parse
from html.parser import HTMLParser

class MLStripper(HTMLParser):
    def __init__(self):
        super().__init__()
        self.reset()
        self.strict = False
        self.convert_charrefs= True
        self.fed = []
    def handle_data(self, d):
        self.fed.append(d)
    def get_data(self):
        return ''.join(self.fed)

url = "https://lite.duckduckgo.com/lite/"
data = urllib.parse.urlencode({'q': 'LG Gram linux keyboard not working after resume from suspend site:reddit.com OR site:unix.stackexchange.com'}).encode('utf-8')
req = urllib.request.Request(url, data=data, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        html = response.read().decode('utf-8')
        s = MLStripper()
        s.feed(html)
        print(s.get_data())
except Exception as e:
    print(e)
