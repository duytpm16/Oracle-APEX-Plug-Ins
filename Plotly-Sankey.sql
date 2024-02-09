----------------------------------------------------------------------------------
--
-- Renders a Plotly Sankey plot using data returned from the SQL query.
--
----------------------------------------------------------------------------------
function render(
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean
) 
return apex_plugin.t_region_render_result is

BEGIN
DECLARE
 
    query_result apex_plugin_util.t_column_value_list;

    HEIGHT number := nvl(p_region.attribute_01, 450);
    
BEGIN
    -- get the SQL source which we are going to insert into the JavaScript that renders the chart.
    query_result := apex_plugin_util.get_data (
        p_sql_statement  => p_region.source,
        p_min_columns    => 1,
        p_max_columns    => 20,
        p_component_name => p_region.name
    ); 


    -- include highchart libs
    HTP.p ('<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>');
   
    HTP.p ('<div id="tester" style="height:' || HEIGHT || 'px;"></div>');
    HTP.p ('<script>');
    HTP.p ('sankeyData = getData();');    
    HTP.p ('
        var options = {
            type: "sankey",
            orientation: "h",

            node: {
                pad: 15,
                thickness: 10,
                line: {
                    color: "black",
                    width: 0.5
                },
                label: sankeyData.labels,
                color: sankeyData.nodeColors
            },

            link: {
                source: sankeyData.source,
                target: sankeyData.target,
                value:  sankeyData.values,
                color:  sankeyData.linkColors
            }
        }

        var options = [options]

        var layout = {
            title: null,

            font: {
                size: 10
            },

            margin: {
                t: 5,
                b: 10,
                l: 0,
                r: 0
            }
        }

        Plotly.react("tester", options, layout);
    ');

    -- get the data fro SQL source and put it into JS code.
    HTP.p ('function getData() {
    var labelDict = {};
    var sourceLabel = [];
    var targetLabel = [];
    var source = [];
    var target = [];
    var values = [];
    var plotlyColors = [
        "#1f77b4",  // muted blue
        "#ff7f0e",  // safety orange
        "#2ca02c",  // cooked asparagus green
        "#d62728",  // brick red
        "#9467bd",  // muted purple
        "#8c564b",  // chestnut brown
        "#e377c2",  // raspberry yogurt pink
        "#7f7f7f",  // middle gray
        "#bcbd22",  // curry yellow-green
        "#17becf"   // blue-teal
    ];
    var plotlyRBG = [
        "rgba(31,119,180, 0.4)",  // muted blue
        "rgba(255,127,14, 0.4)",  // safety orange
        "rgba(44,160,44, 0.4)",  // cooked asparagus green
        "rgba(214,39,40, 0.4)",  // brick red
        "rgba(148,103,189, 0.4)",  // muted purple
        "rgba(140,86,75, 0.4)",  // chestnut brown
        "rgba(227,119,194, 0.4)",  // raspberry yogurt pink
        "rgba(127,127,127, 0.4)",  // middle gray
        "rgba(188,189,34, 0.4)",  // curry yellow-green
        "rgba(23,190,207, 0.4)"   // blue-teal
    ];');
    for rowNumber in query_result(1).first .. query_result(1).last loop  
        HTP.p ('    sourceLabel.push("' || query_result(1)(rowNumber) || '");');
        HTP.p ('    source.push(' || query_result(2)(rowNumber) || ');');
        HTP.p ('    targetLabel.push("' || query_result(3)(rowNumber) || '");');        
        HTP.p ('    target.push(' || query_result(4)(rowNumber) || ');');
        HTP.p ('    values.push(' || query_result(5)(rowNumber) || ');');
        HTP.p ('    if (labelDict[source.slice(-1)] === undefined) {
        labelDict[source.slice(-1)] = sourceLabel.slice(-1);
    }
    if (labelDict[target.slice(-1)] === undefined) {
        labelDict[target.slice(-1)] = targetLabel.slice(-1);
    }');

        
        -- HTP.p ('    colors.push("' || query_result(6)(rowNumber) || '");');
    end loop;
 
    HTP.p ('    var labelIndex = Object.keys(labelDict);
    var newIndex = Array.from({ length: Math.max(...labelIndex) + 1 }, (_, index) => index);

    var labels = newIndex.map(key => labelDict[key] !== undefined ? labelDict[key] : "");
    var nodeColors = newIndex.map(key => plotlyColors[key]);
    var linkColors = source.map(key => plotlyRBG[key]);');
    HTP.p ('    return {labels: labels, source: source, target: target, values: values, nodeColors: nodeColors, linkColors: linkColors};
    }');

    HTP.p ('</script>');

return null;
end;
end;