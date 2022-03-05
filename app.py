from asyncio import futures
from flask import Flask,render_template, Markup
import plotly.offline as pyo
import os 
import pandas as pd
import networkChart

WC_FOLDER = "static/"

df = pd.read_csv("./Data/generated/cast_network.csv")
cast_G = networkChart.generateGraph(df)


app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = WC_FOLDER

@app.route("/squid_wc")
def getWordCloudSquid():
    full_filename = os.path.join(app.config['UPLOAD_FOLDER'], 'squid_hash_wc.png')
    print (full_filename)
    return render_template('wc.html', wc_img = full_filename )

@app.route("/cast_network/<cast>")
def getCastNetwork(cast):

    fig = networkChart.getCastNetwork(cast_G, cast)
    chart_div_string = pyo.offline.plot(fig, include_plotlyjs=False, output_type='div')
    chart_div_for_use_in_jinja_template = Markup(chart_div_string)
    return render_template('network.html', chart=chart_div_for_use_in_jinja_template )

if __name__ == "__main__":
    app.run(debug = True)