#!/usr/bin/env python3
"""
Author        :Julio Sanz
Website       :www.elarraydejota.com
Email         :juliojosesb@gmail.com
Description   :Script to convert HTML to image
Dependencies  :Python 3.x, imgkit and wkhtmltopdf
Usage         :python3 html2img.py [html_filename] [img_filename]
License       :GPLv3
"""

import sys,imgkit

html_filename=sys.argv[1]
img_filename=sys.argv[2]

def convert_html2img():
	imgkit.from_file(html_filename, img_filename)


#
# MAIN
# 

if __name__ == '__main__':
    convert_html2img()