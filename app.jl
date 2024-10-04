using Dash
using Sockets
using CSV
using DataFrames
using Dates
using PlotlyJS
using Statistics
using Missings

df_holi = CSV.read("data/holidays_events.csv", DataFrames.DataFrame)
df_oil = CSV.read("data/oil.csv", DataFrames.DataFrame)
df_stores = CSV.read("data/stores.csv", DataFrames.DataFrame)
df_trans = CSV.read("data/transactions.csv", DataFrames.DataFrame)
df_train = CSV.read("data/train.csv", DataFrames.DataFrame)
df_test = CSV.read("data/test.csv", DataFrames.DataFrame)

first_date = string(df_train.date[1])
last_date = string(df_train.date[end])

df_train1 = innerjoin(df_train, df_holi, on = :date, makeunique=true)
df_train1 = innerjoin(df_train1, df_oil, on = :date, makeunique=true)
df_train1 = innerjoin(df_train1, df_stores, on = :store_nbr, makeunique=true)
df_train1 = innerjoin(df_train1, df_trans, on = [:date, :store_nbr], makeunique=true)
rename!(df_train1, :type => :holiday_type, :type_1 => :store_type)

df_train1.date = Date.(df_train1.date)
df_train1.year = year.(df_train1.date)
df_train1.month = month.(df_train1.date)
df_train1.week = Dates.week.(df_train1.date)
df_train1.quarter = quarterofyear.(df_train1.date)
df_train1.day_of_week = dayname.(df_train1.date)

sample_df = df_train1[rand(1:nrow(df_train1), 4), :]

df_fa_sa = combine(groupby(df_train1, :family), :sales => mean => :mean_sales)
# Round the mean_sales column to integers
df_fa_sa[:, :mean_sales] .= round.(Int, df_fa_sa[:, :mean_sales])

mean_sales = df_fa_sa[:, :mean_sales]
df_fa_sa = sort(df_fa_sa, :mean_sales, rev=true)[1:10, :]

# Define the figure
fig1 = PlotlyJS.plot(
    [PlotlyJS.bar(
        x = df_fa_sa.mean_sales,
        y = df_fa_sa.family,
        orientation = "h",
        marker_color = repeat(["#441aff", "#6748fe", "#7053fe", "#8973fd", "#927efd", "#9988fd", "#b0a6fc", "#c6c2fb", "#d6d6fb", "#e7ecfa"]),
        text = string.(Int.(df_fa_sa.mean_sales)),
        textposition = "auto",
        hoverinfo = "text",
        hovertext = string.(
            "<b>Family</b>: ", df_fa_sa.family, "<br>",
            "<b>Sales</b>: ", string.(Int.(df_fa_sa.mean_sales))
        )
    )],
    Layout(
        title = "The 10 Best-Selling Products",
        font = attr(size=14, color="#35447c", family="Microsoft Sans Serif"),
        paper_bgcolor = "#ffffff",  # Set background color to white
        plot_bgcolor = "#ffffff",
        yaxis = attr(
            showgrid=false,
            categoryorder="total ascending",
            tickfont = attr(size=12),  # Adjust the font size of y-axis labels
        ),
        xaxis = attr(
            tickfont = attr(size=12),
            gridcolor="#e7ecfa"
        )
    )
)

#fig 2
df_st_sa = combine(groupby(df_train1, :store_type), :sales => mean => :mean_sales)
df_st_sa[:, :mean_sales] .= round.(Int, df_st_sa[:, :mean_sales])

mean_sales = df_st_sa[:, :mean_sales]
df_st_sa = sort(df_st_sa, :mean_sales, rev=true)

# Create the pie chart
fig2 = plot(
    pie(
        labels = df_st_sa.store_type,
        values = df_st_sa.mean_sales,
        #marker_colors = ["#03DAC6", "#17acce", "#467ad5", "#6200ee", "#3d1871"],
        marker_colors = repeat(["#e7ecfa", "#c6c2fb", "#9988fd", "#7053fe", "#441aff"]),
        hole = 0.7,
        hoverinfo = "label+percent+value",
        textinfo = "label"
    ),
    Layout(
        title = "The Average Sales Vs Store Types",
        paper_bgcolor = "#ffffff",
        plot_bgcolor = "#ffffff",
        font = attr(size=14, color="#35447c", family="Microsoft Sans Serif"),
        yaxis = attr(showgrid=false, categoryorder="total ascending"),
    )
)

df_state_sa = combine(groupby(df_train1, :state), :sales => mean => :mean_sales)

# Convert the :mean_sales column to Float64 if it's not already
df_state_sa[:, :mean_sales] .= Float64.(df_state_sa[:, :mean_sales])

# Round the mean_sales column to integers
df_state_sa[:, :rounded_mean_sales] .= round.(Int, df_state_sa[:, :mean_sales])

# Sort the DataFrame by the :rounded_mean_sales column in descending order
df_state_sa = sort(df_state_sa, :rounded_mean_sales, rev=true)[1:5, :]

fig3 = plot(
    bar(
        x = df_state_sa.state,
        y = df_state_sa.rounded_mean_sales,
        name = "State",
        marker_colors = "#7053fe",
        text = string.(Int.(df_state_sa.rounded_mean_sales)),
        textposition = "auto",
        hoverinfo = "text",
        hovertext = string.(
            "<b>State</b>: ", string.(df_state_sa.state), "<br>",
            "<b>Sales</b>: ", string.(Int.(df_state_sa.rounded_mean_sales))
        )
    ),
    Layout(
        title = "The Average Sales Vs States",
        paper_bgcolor = "#ffffff",
        plot_bgcolor = "#ffffff",
        font = attr(size=14, color="#35447c", family="Microsoft Sans Serif"),
        xaxis = attr(color="#3700B3"),  # Set the x-axis label color
        yaxis = attr(color="#3700B3",categoryorder="total ascending",gridcolor="#e7ecfa")
    )
)

#fig4

df_qu_sa = combine(groupby(df_train1, :quarter), :sales => mean => :mean_sales)
df_qu_sa[:, :mean_sales] .= Float64.(df_qu_sa[:, :mean_sales])
df_qu_sa[:, :rounded_mean_sales] .= round.(Int, df_qu_sa[:, :mean_sales])

fig4 = plot(
    scatter(
        x = df_qu_sa.quarter,
        y = df_qu_sa.rounded_mean_sales,
        fill = "tozeroy",
        fillcolor = "rgba(179, 163, 255, 0.15)",
        line = attr(color = "#441aff"),
        mode = "lines"
    ),
    Layout(
        title = "The Average Quarterly Sales",
        height = 300,
        paper_bgcolor = "#ffffff",
        plot_bgcolor = "#ffffff",
        font = attr(size = 12, color = "#35447c", family="Microsoft Sans Serif"),
        xaxis = attr(showgrid = false, tickmode = "array", tickvals = df_qu_sa.quarter, gridcolor="#e7ecfa"),
        yaxis = attr(gridcolor="#e7ecfa")
    )
)

df_day_sa = combine(groupby(df_train1, :date), :sales => mean => :mean_sales)

fig5 = plot(
    scatter(
        x = df_day_sa.date,
        y = df_day_sa.mean_sales,
        fill = "tozeroy",
        fillcolor = "rgba(179, 163, 255, 0.15)",
        line = attr(color = "#441aff"),
        mode = "lines"
    ),
    Layout(
        title = "The Average Daily Sales",
        height = 300,
        paper_bgcolor = "#ffffff",
        plot_bgcolor = "#ffffff",
        font = attr(size = 12, color = "#35447c", family="Microsoft Sans Serif"),
        xaxis = attr(showgrid = false),
        yaxis = attr(gridcolor="#e7ecfa")
    )
)

port = 8050

app = dash(requests_pathname_prefix="/proxy/$port/")
box_style = Dict(
    "border-radius" => "10px",
    "align-items" => "center",
    "backgroundColor" => "#ffffff",
    "justify-content" => "space-around",
    "padding" => "15px",
    "box-shadow" => "3px 3px 10px rgba(0, 30, 87, 0.2)"
)

box_style2 = Dict(
    "border-radius" => "20px",
    "backgroundColor" => "#ffffff",
    "justify-content" => "space-around",
    "textAlign" => "center",
    "box-shadow" => "3px 3px 10px rgba(0, 30, 87, 0.2)",
    "padding" => "10px",
    "margin" => "0",
    "color" => "#35447c"
)

box_style3 = Dict(
    "border-radius" => "20px",
    "backgroundColor" => "#ffffff",
    "justify-content" => "space-around",
    "box-shadow" => "3px 3px 10px rgba(0, 30, 87, 0.2)",
    "padding" => "10px",
    "margin" => "0",
    "color" => "#35447c",
    "width" => "100%"
)

stores_num = nrow(df_stores)
type_store_num = nrow(combine(groupby(df_stores, :type), nrow))
product_num = nrow(combine(groupby(df_train, :family), nrow))
cities_num = nrow(combine(groupby(df_stores, :city), nrow))
state_num = nrow(combine(groupby(df_stores, :state), nrow))

first_date = df_train[1, "date"]
last_date = df_train[end, "date"]

available_states = unique(df_train1[:, "state"])
# Wrapping the content in a div element
app.layout = html_div(
    style = Dict("backgroundColor" => "#ffffff", "width" => "100vw", "overflow-y" => "initial","margin" => "0"),
    children= [
        html_br(),
        html_h1(
        "Julia Performance Dashboard App",
        style = Dict("color" => "#ffffff", "textAlign" => "left","backgroundColor" => "#7053fe", "margin" => "0","padding"=>"5px")
    ),
    html_div(
        "Sales for 1000s of products sold at favourite stores located in South America’s west coast Ecuador.",
        style = Dict("color" => "#f5f7fe", "textAlign" => "left","padding"=>"5px","backgroundColor" => "#7053fe", "margin" => "0")
    ),
    html_br(), #7053fe
    html_div(
        id="um",
        children=[
            html_div(children=[html_h2("Stores:",style=Dict("margin"=>"0","padding"=>"5px","font-size" => "31px","color" => "#35447c")),html_div("$stores_num",style=Dict("margin-top"=>"0px", "font-size" => "28px","padding"=>"5px","color" => "#35447c"))],style=box_style2),
            html_div(children=[html_h2("Cities:",style=Dict("margin"=>"0","padding"=>"5px","font-size" => "31px","color" => "#35447c")),html_div("$cities_num",style=Dict("margin-top"=>"0px", "font-size" => "28px","padding"=>"5px","color" => "#35447c"))],style=box_style2),
            html_div(children=[html_h2("States:",style=Dict("margin"=>"0","padding"=>"5px","font-size" => "31px","color" => "#35447c")),html_div("$state_num",style=Dict("margin-top"=>"0px", "font-size" => "28px","padding"=>"5px","color" => "#35447c"))],style=box_style2),
            html_div(children=[html_h2("Store Types:",style=Dict("margin"=>"0","padding"=>"5px","font-size" => "31px","color" => "#35447c")),html_div("$type_store_num",style=Dict("margin-top"=>"0px", "font-size" => "28px","padding"=>"5px","color" => "#35447c"))],style=box_style2),
            html_div(children=[html_h2("Products:",style=Dict("margin"=>"0","padding"=>"5px","font-size" => "31px","color" => "#35447c")),html_div("$product_num",style=Dict("margin-top"=>"0px", "font-size" => "28px","padding"=>"5px","color" => "#35447c"))],style=box_style2),
            html_div(children=[html_h2("Cluster:",style=Dict("margin"=>"0","padding"=>"5px","font-size" => "31px","color" => "#35447c")),html_div("17",style=Dict("margin-top"=>"0px", "font-size" => "28px","padding"=>"5px","color" => "#35447c"))],style=box_style2),
        ],
        style = Dict("grid-template-columns" => "16% 16% 16% 16% 16% 16%", "display" => "grid","backgroundColor" => "#f5f7fe","width" => "96%","align-items" => "center","gap" => "23px","padding" => "3px")
    ),
    html_br(),
    html_br(),
    html_div(
        id="left",
        children=[
            html_div(dcc_graph(id="best-selling-state", figure=fig3), className="box",style=box_style),
            html_div(dcc_graph(id="store-average-sales", figure=fig2), className="box",style=box_style),
            html_div(dcc_graph(id="products-average-sales", figure=fig1), className="box",style=box_style),
            html_br()
        ],
        style = Dict("grid-template-columns" => "33% 33% 33%", "display" => "grid","backgroundColor" => "#f5f7fe","width" => "97%","align-items" => "center","gap" => "12px","padding" => "5px")
    ),
    html_div(
        id="yay",
        children=[
            html_div(dcc_graph(id="avg-quarter-sales", figure=fig4), className="box",style=box_style),
            html_div(dcc_graph(id="avg-month-sales", figure=fig5), className="box",style=box_style),
            html_br()
        ],
        style = Dict("grid-template-columns" => "50% 50%", "display" => "grid","backgroundColor" => "#f5f7fe","width" => "97%","align-items" => "center","gap" => "12px","padding" => "5px")
    ),
    html_div(
    children = [
        dcc_dropdown(
            id = "selected-state",
            options = [Dict("label" => state, "value" => state) for state in available_states],
            value = nothing,
            placeholder = "Select a State",
            style=Dict(
                "border-radius" => "20px",
                "backgroundColor" => "#ffffff",
                "font-size" => "13px",
                "color" => "#35447c",
                "font-family" => "Microsoft Sans Serif"
            )
        ),
        dcc_graph(id="top-products-graph")
    ],
    className="box",
    style=box_style3
)
]
)

callback!(
    app,
    Output("top-products-graph", "figure"),
    [Input("selected-state", "value")]
) do selected_state
    if selected_state !== nothing
        df_state = filter(row -> row.state == selected_state, df_train1)
        
        df_family_mean_sales = combine(groupby(df_state, :family), :sales => mean => :mean_sales)
        
        df_top_10 = first(sort(df_family_mean_sales, :mean_sales, rev=true), 10)
        
        if !isempty(df_top_10)
            fig = plot(
                bar(
                    x = df_top_10.family,
                    y = df_top_10.mean_sales,
                    marker_color = repeat(["#441aff", "#6748fe", "#7053fe", "#8973fd", "#927efd", "#9988fd", "#b0a6fc", "#c6c2fb", "#d6d6fb", "#e7ecfa"])
                ),
                Layout(
                    title = "Top 10 Products by Mean Sales in $selected_state",
                    xaxis_title = "State",
                    yaxis_title = "Mean Sales",
                    height = "900",
                    barmode = "group",
                    font = attr(size=16, color="#35447c", family="Microsoft Sans Serif"),
                    paper_bgcolor = "#ffffff",  # Set background color to white
                    plot_bgcolor = "#ffffff",
                    yaxis = attr(gridcolor="#e7ecfa")
                )
            )
            return fig
        else
            return PlotlyJS.Plot(data=[], layout=Layout())
        end
    else
        return PlotlyJS.Plot(Layout(paper_bgcolor = "#ffffff",plot_bgcolor = "#ffffff"))
    end
end
port=8050
run_server(app, "0.0.0.0", port, debug=true)