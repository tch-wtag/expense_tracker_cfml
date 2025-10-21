component displayname="BaseRepository" hint="Base repository with common database operations" {
    property name="datasource" type="string" default="mydsn";
    public function init(string datasource="mydsn") {
        variables.datasource = arguments.datasource;
        return this;
    }
    public function executeQuery(required string sql, struct params={}) {
        var q = new Query();
        q.setDatasource(variables.datasource);
        q.setSQL(arguments.sql);
        
        for (var key in arguments.params) {
            var paramStruct = arguments.params[key];
            var addParamArgs = {
                name = key,
                value = paramStruct.value,
                cfsqltype = paramStruct.type
            };
            if (structKeyExists(paramStruct, "null") && paramStruct.null) {
                addParamArgs.null = true;
            }
            q.addParam(argumentCollection = addParamArgs);
        }
        return q.execute().getResult();
    }

    public function executeUpdate(required string sql, struct params={}) {
        var q = new Query();
        q.setDatasource(variables.datasource);
        q.setSQL(arguments.sql);
        
        for (var key in arguments.params) {
            var paramStruct = arguments.params[key];
            var addParamArgs = {
                name = key,
                value = paramStruct.value,
                cfsqltype = paramStruct.type
            };
            
            if (structKeyExists(paramStruct, "null") && paramStruct.null) {
                addParamArgs.null = true;
            }
            q.addParam(argumentCollection = addParamArgs);
        }
        
        var result = q.execute();
        return result.getPrefix();
    }

    public function beginTransaction() {
        transaction action="begin" {};
    }
    public function commitTransaction() {
        transaction action="commit" {};
    }
    public function rollbackTransaction() {
        transaction action="rollback" {};
    }
    public array function queryToArray(required query qry) {
        var result = [];
        var cols = listToArray(arguments.qry.columnList);
        for (var i = 1; i <= arguments.qry.recordCount; i++) {
            var row = {};
            for (var col in cols) {
                row[col] = arguments.qry[col][i];
            }
            arrayAppend(result, row);
        }
        return result;
    }
}