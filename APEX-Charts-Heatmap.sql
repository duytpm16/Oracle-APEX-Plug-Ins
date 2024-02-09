----------------------------------------------------------------------------------
--
-- Renders a APEX Charts Heatmap using data returned from the SQL query.
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

    HEIGHT integer := nvl(p_region.attribute_01, 450);
    FONTSIZE integer := nvl(p_region.attribute_02, 14);
    
BEGIN
    -- get the SQL source which we are going to insert into the JavaScript that renders the chart.
    query_result := apex_plugin_util.get_data (
        p_sql_statement  => p_region.source,
        p_min_columns    => 1,
        p_max_columns    => 20,
        p_component_name => p_region.name
    ); 


    -- include highchart libs
    HTP.p ('<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>');
   
    HTP.p ('<div id="chart"></div>');
    HTP.p ('<script>');
    HTP.p ('var data = getData();');
    HTP.p ('
        var options = {
            series: data,
            
            colors: ["#E3E3E3", "#F3DE8A", "#CAE7B9"],
            
            dataLabels: {
                enabled: true,
                
                style: {
                    fontSize: "' || FONTSIZE || 'px",
                    colors: ["#000000"]
                },

                formatter: function(val, opt) {
                    return val.toLocaleString("en-US"); 
                }
            },

            plotOptions: {
                heatmap: {
                    enableShades: false
                }
            },

            chart: {
                height: ' || HEIGHT || ',
                type: "heatmap"
            }
        };

        var chart = new ApexCharts(document.querySelector("#chart"), options);
        chart.render();
    ');

    -- get the data fro SQL source and put it into JS code.
    HTP.p ('function getData() {
    var result = [{name: "Inactive", data: []}, {name: "Potential", data: []}, {name: "Active", data: []}];');
    for rowNumber in query_result(1).first .. query_result(1).last loop  
        HTP.p ('    result[0].data.push({x: "' || query_result(1)(rowNumber) || '", y: ' || query_result(4)(rowNumber) || '});');
        HTP.p ('    result[1].data.push({x: "' || query_result(1)(rowNumber) || '", y: ' || query_result(3)(rowNumber) || '});');
        HTP.p ('    result[2].data.push({x: "' || query_result(1)(rowNumber) || '", y: ' || query_result(2)(rowNumber) || '});');
    end loop;

    HTP.p ('    return result;
    }');

    HTP.p ('</script>');

return null;
end;
end;