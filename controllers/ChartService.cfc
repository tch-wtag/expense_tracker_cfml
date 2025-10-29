<cfcomponent output="false" displayname="ChartService">

    <cffunction name="generateDailySpendingChart" access="public" returntype="void">
        <cfargument name="dailyTotals" type="query" required="true">
        <cfargument name="outputPath" type="string" required="true">

        <cfscript>
            // Load required Java classes
            ChartFactory = createObject("java", "org.jfree.chart.ChartFactory");
            DefaultCategoryDataset = createObject("java", "org.jfree.data.category.DefaultCategoryDataset");
            FileOutputStream = createObject("java", "java.io.FileOutputStream");
            ChartUtils = createObject("java", "org.jfree.chart.ChartUtils");

            dataset = DefaultCategoryDataset.init();

            // Populate dataset from query
            for (row=1; row <= arguments.dailyTotals.recordCount; row++) {
                dataset.addValue(
                    arguments.dailyTotals.daily_total[row],        
                    "Spending",                                    
                    dateFormat(arguments.dailyTotals.expense_date[row], "mmm dd") 
                );
            }

            // Create bar chart
            chart = ChartFactory.createBarChart(
                "Daily Spending (Last 7 Days)", 
                "Date",                         
                "Amount",                       
                dataset
            );

            // Save as PNG using FileOutputStream
            fos = FileOutputStream.init(arguments.outputPath);
            ChartUtils.writeChartAsPNG(fos, chart, 800, 400);
            fos.close();
        </cfscript>
    </cffunction>

</cfcomponent>

