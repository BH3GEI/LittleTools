import os
import requests
import threading
from urllib.parse import urlparse
from tkinter import filedialog, Text, Button, Toplevel, Tk, ttk
import re
import mimetypes
import errno

from tqdm import tqdm


class InputDialog(Toplevel):
    def __init__(self, parent):
        Toplevel.__init__(self, parent)
        self.title("请输入包含链接的字符串")
        self.text = Text(self, width=80, height=20)
        self.text.pack()
        self.button = Button(self, text="确定", command=self.ok)
        self.button.pack()

    def ok(self):
        self.input_string = self.text.get(1.0, "end")
        self.destroy()

def download_file(url, file_path):
    try:
        with requests.get(url, stream=True) as r:
            r.raise_for_status()
            total_size = int(r.headers.get('content-length', 0))
            block_size = 1024 #1 Kibibyte
            t=tqdm(total=total_size, unit='iB', unit_scale=True)
            with open(file_path, 'wb') as f:
                for data in r.iter_content(block_size):
                    t.update(len(data))
                    f.write(data)
            t.close()
            if total_size != 0 and t.n != total_size:
                print("ERROR, something went wrong")
    except Exception as e:
        print(f"Failed to download {url} to {file_path} due to {str(e)}~")

root = Tk()
root.withdraw()

dialog = InputDialog(root)
root.wait_window(dialog)
input_string = dialog.input_string

urls = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', input_string)

download_dir = filedialog.askdirectory()

for url in urls:
    path = urlparse(url).path
    filename = os.path.basename(path)


    if filename == "":
        response = requests.head(url)
        if 'Content-Type' in response.headers:
            content_type = response.headers['Content-Type']
            ext = mimetypes.guess_extension(content_type)
            filename = "downloaded_file" + (ext if ext else "")

    file_path = os.path.join(download_dir, filename)

    if not os.path.exists(os.path.dirname(file_path)):
        try:
            os.makedirs(os.path.dirname(file_path))
        except OSError as exc: # Guard against race condition
            if exc.errno != errno.EEXIST:
                print(f"Failed to create directory due to {str(exc)}~")
                continue
                
    threading.Thread(target=download_file, args=(url, file_path)).start()
