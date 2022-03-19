import plotly.graph_objects as go
import networkx as nx
import pandas as pd

def generateGraph(df, min_weight = 0):
    G = nx.Graph()

    for index, row in df.iterrows():
        if (row["count"] > min_weight): # more than 3 shows together
            G.add_node(row["cast1"])
            G.add_node(row["cast2"])
            G.add_edge(row["cast1"], row["cast2"], weight = row["count"])
    return G

def getCastNetwork(G, show, casts):
    
    all_casts_nodes = []

    for cast in casts: 
        for adj in G.adjacency():
            if (adj[0] == cast):
                subG_nodes = [adj[0]]
                subG_nodes += adj[1].keys()
                break
        all_casts_nodes += subG_nodes
    
    if (all_casts_nodes == []):
        return False

    G = G.subgraph(all_casts_nodes)

    pos_ = nx.spring_layout(G)

    edge_x = []
    edge_y = []
    edge_width = []

    for edge in G.edges():
        x0, y0 = pos_[edge[0]][0], pos_[edge[0]][1]
        x1, y1 = pos_[edge[1]][0], pos_[edge[1]][1]
        edge_width.append(G[edge[0]][edge[1]]["weight"])
        edge_x.append([x0,x1,None])
        edge_y.append([y0,y1,None])
        
    edge_trace = []
    for i in range(len(edge_x)):
        trace = go.Scatter(
            x = edge_x[i], y = edge_y[i],
            line=dict(width=edge_width[i] * 0.5, color='#888'),
            text=edge_width[i],
            hoverinfo = 'text',
            mode='lines')
        edge_trace.append(trace)
        
    node_x = []
    node_y = []

    cast_x = []
    cast_y = []

    cast_label = []
    for node in G.nodes():
        x, y = pos_[node][0], pos_[node][1] 
        node_x.append(x)
        node_y.append(y)
        if (node in casts): 
            cast_x.append(x)
            cast_y.append(y)
            cast_label.append(node)

    search_trace = go.Scatter(
        x=cast_x, y=cast_y,
        mode='markers+text',
        text = cast_label,
        textposition="top center",
        marker=dict(
            color='red',
            line_width=0))

    node_trace = go.Scatter(
        x=node_x, y=node_y,
        mode='markers',
        hoverinfo='text',
        marker=dict(
            showscale=True,
            # colorscale options
            #'Greys' | 'YlGnBu' | 'Greens' | 'YlOrRd' | 'Bluered' | 'RdBu' |
            #'Reds' | 'Blues' | 'Picnic' | 'Rainbow' | 'Portland' | 'Jet' |
            #'Hot' | 'Blackbody' | 'Earth' | 'Electric' | 'Viridis' |
            colorscale='YlGnBu',
            reversescale=True,
            color=[],
            colorbar=dict(
                thickness=15,
                title='Node Connections',
                xanchor='left',
                titleside='right'
            ),
            line_width=2))

    node_adjacencies = []
    node_text = []
    for node, adjacencies in enumerate(G.adjacency()):
        node_adjacencies.append(len(adjacencies[1]))
        node_text.append(f'{adjacencies[0]} has {len(adjacencies[1])} connection(s)')

    node_trace.marker.color = node_adjacencies
    node_trace.text = node_text

    fig = go.Figure(data=edge_trace + [node_trace] + [search_trace],
                layout=go.Layout(
                    title=f'{show}\'s Cast Network Graph',
                    titlefont_size=16,
                    showlegend=False,
                    hovermode='closest',
                    margin=dict(b=20,l=5,r=5,t=40),
                    xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                    yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),          
                    autosize=False,
                    width=700,
                    height=800)
                    )
                    
    return fig
