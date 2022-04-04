import pandas as pd
import re
import glob 

import plotly.graph_objects as go

FILE_DIR = "Data/tweets/"
FILE_DIR_UNPOP = "Data/unpop_tweets/"

def getCSVdata(file):
    data = pd.read_csv(file)
    data = data.mean(numeric_only=True)
    data['title'] = file.split("/")[-1].split('.')[0]
    return data

def getData(): 
    df = pd.DataFrame()
    csv_files = glob.glob(f"{FILE_DIR}processed/*.csv")
    for file in csv_files: 
        data = getCSVdata(file)
        df = df.append(data, ignore_index=True)

    df.drop("Unnamed: 0", axis = 1, inplace = True)

    unpop_df = pd.DataFrame()
    csv_files = glob.glob(f"{FILE_DIR_UNPOP}processed/*.csv")
    for file in csv_files: 
        data = getCSVdata(file)
        unpop_df = unpop_df.append(data, ignore_index=True)

    unpop_df.drop("Unnamed: 0", axis = 1, inplace = True)
    return df, unpop_df

def genEmoRadar(df,showType):
    categories = ['angry', 'fear', 'happy',
       'sad', 'surprise']
    
    emotions_df = df[categories]
    emotions_df["title"] = df.title
    
    fig = go.Figure( 
        layout=go.Layout(
                    title=f'Emotions of {showType} shows on Netflix',
                    width=500,
                    height=500))   

    for i, row in emotions_df.iterrows(): 
        fig.add_trace(go.Scatterpolar(
            r=row.values[0:5],
            theta=categories,
            fill='toself',
            name=row[-1]
        ))

    fig.update_layout(
    polar=dict(
        radialaxis=dict(
        visible=True
        ),
    ),
    showlegend=False
    )

    return fig


def genSentRadar(df,showType):
    categories = ['neg','neu','pos','comp']
    
    sentiment_df = df[categories]
    sentiment_df["title"] = df.title

    fig = go.Figure( 
        layout=go.Layout(
                    title=f'Sentiments of {showType} shows on Netflix',
                    width=500,
                    height=500))   

    for i, row in sentiment_df.iterrows(): 
        #print(row[:5])
        fig.add_trace(go.Scatterpolar(
            r=row.values[0:5],
            theta=categories,
            fill='toself',
            name=row[-1]
        ))

    fig.update_layout(
    polar=dict(
        radialaxis=dict(
        visible=True
        ),
    ),
    showlegend=False
    )

    return fig