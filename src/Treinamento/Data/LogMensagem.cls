Class Treinamento.Data.LogMensagem Extends (%Persistent, %XML.Adaptor)
{
    Property Metodo As %String(MAXLEN="") [SqlColumnNumber = 2];
    Property Classe As %String(MAXLEN="") [SqlColumnNumber = 3];
    Property Inicio As %String [ SqlColumnNumber = 4];
    Property Fim As %String [ SqlColumnNumber = 5 ];
    Property Status As %Boolean [ SqlColumnNumber = 6 ];
    Property StatusProcesso As %String [ SqlColumnNumber = 7 ];
    Property Listalog As list of Treinamento.VO.LogMensagem;

    ClassMethod CriarEntrada(pMetodo As %String, pClasse As %String) As Treinamento.Data.LogMensagem
    {
        Set tSC = $$$OK 
        try
        {
            Set classe               = ..%ClassName()
            Set name                 =   $ZNAME
            #Dim exception           As %Exception.General    = ""
            #Dim statuCode           As %Status               = $SYSTEM.Status.OK()
            #Dim entry               As LogMensagem           = ..%New()
            

            Set entry.Metodo         = pMetodo
            Set entry.Classe         = pClasse
            Set entry.Inicio         = $ZDATETIME($HOROLOG,4)
            set entry.Status         = statuCode
            SET statusCode           = entry.%Save()
        }
        catch(exception) 
        {
            Set tSC                  = exception.AsStatus() 
            Set errorMensagem        = $SYSTEM.Status.GetOneErrorText(tSC)
            Throw exception
        }   

        return entry

    }

    ClassMethod Finalizar(pIdLog As %Integer, pStatusProcesso As %String, pStatusCode As %String) As Treinamento.Data.LogMensagem
    {
        Set tSC = $$$OK 

        try
        {
            #Dim exception           As %Exception.General    = ""
            #Dim statuCode           As %Status               = $SYSTEM.Status.OK()
            #Dim entry               As LogMensagem           = ..%OpenId(pIdLog)
            
            Set entry.Fim            = $ZDATETIME($HOROLOG,4)
            Set entry.StatusProcesso = pStatusProcesso        
            set entry.Status         = statuCode
            SET statusCode           = entry.%Save()
        }

        catch(exception) 
        {
            Set tSC                  = exception.AsStatus() 
            Set errorMensagem        = $SYSTEM.Status.GetOneErrorText(tSC)
            Throw exception
        }   

        return entry
    }

    ClassMethod ConsultaLog(pStatus As %Boolean, pDataInicio As %String, pDataFim As %String) As Treinamento.Data.LogMensagem
    {
        #Dim statusCode              As %Status               = $$$OK
        #Dim exception               As %Exception.General    = ""
        #Dim SQL                     As %String
        #Dim statement               As %SQL.Statement
        #Dim resultSet               As %SQL.StatementResult
        #Dim entry                   As Treinamento.Data.LogMensagem
                
        Try
        {
            Set entry = ..%New()
            
            Set SQL = "SELECT ID, Metodo, Classe, Inicio, Fim, Status, StatusProcesso " _
                      "FROM Treinamento.Data.LogMensagem " _
                      "WHERE Status = ? AND Inicio BETWEEN ? AND ? " _
                      "ORDER BY ID DESC"
           
            Set statement = ##class(%SQL.Statement).%New()
            Set statusCode = statement.%Prepare(SQL)
            If $$$ISERR(statusCode) Throw ##class(%Exception.StatusException).CreateFromStatus(statusCode)
            
            Set resultSet = statement.%Execute(pStatus, pDataInicio, pDataFim)
            
            While (resultSet.%Next())
            {
                Set pItem = ##class(Treinamento.VO.LogMensagem).%New()
                Set pItem.Metodo          = resultSet.%Get("Metodo")
                Set pItem.Classe          = resultSet.%Get("Classe")
                Set pItem.Inicio          = resultSet.%Get("Inicio")
                Set pItem.Fim             = resultSet.%Get("Fim")
                Set pItem.Status          = resultSet.%Get("Status")
                Set pItem.StatusProcesso  = resultSet.%Get("StatusProcesso")
                
                Do entry.Listalog.Insert(pItem)
            }
        }
        Catch(exception) 
        {
            Throw exception
        }   
        Return entry
    }

    ClassMethod ConsultaLogPaginacao(pStatus As %Boolean, pLastId As %Integer, pPagSize As %Integer, pDataFim As %String) As Treinamento.Data.LogMensagem
    {
        #Dim statusCode              As %Status               = $$$OK
        #Dim exception               As %Exception.General    = ""
        #Dim SQL                     As %String
        #Dim statement               As %SQL.Statement
        #Dim resultSet               As %SQL.StatementResult
        #Dim entry                   As Treinamento.Data.LogMensagem
                
        Try
        {
            Set entry = ..%New()
            If (pPagSize <= 0) Set pPagSize = 10
            
            Set SQL = "SELECT ID, Metodo, Classe, Inicio, Fim, Status, StatusProcesso " _
                      "FROM Treinamento.Data.LogMensagem " _
                      "WHERE Status = ? "
            
            If (pLastId > 0) 
            {
                Set SQL = SQL _ "AND ID < ? "
            }
            
            If (pDataFim'="") 
            {
                Set SQL = SQL _ "AND Inicio <= ? "
            }
            
            Set SQL = SQL _ "ORDER BY ID DESC LIMIT ?"
           
            Set statement = ##class(%SQL.Statement).%New()
            Set statusCode = statement.%Prepare(SQL)
            If $$$ISERR(statusCode) Throw ##class(%Exception.StatusException).CreateFromStatus(statusCode)
            
    
            If (pLastId > 0) && (pDataFim '= "") 
            {
                Set resultSet = statement.%Execute(pStatus, pLastId, pDataFim, pPagSize)
            } 
            Elseif (pLastId > 0) 
            {
                Set resultSet = statement.%Execute(pStatus, pLastId, pPagSize)
            } 
            Elseif (pDataFim '= "") 
            {
                Set resultSet = statement.%Execute(pStatus, pDataFim, pPagSize)
            } 
            Else 
            {
                Set resultSet = statement.%Execute(pStatus, pPagSize)
            }
            
            While (resultSet.%Next())
            {
                Set pItem = ##class(Treinamento.VO.LogMensagem).%New()
                Set pItem.Metodo          = resultSet.%Get("Metodo")
                Set pItem.Classe          = resultSet.%Get("Classe")
                Set pItem.Inicio          = resultSet.%Get("Inicio")
                Set pItem.Fim             = resultSet.%Get("Fim")
                Set pItem.Status          = resultSet.%Get("Status")
                Set pItem.StatusProcesso  = resultSet.%Get("StatusProcesso")
                
                Do entry.Listalog.Insert(pItem)
            }
        }

        Catch(exception) 
        {
            Throw exception
        }

        Return entry
    }

    ClassMethod BuscarLogPorIdJSON(pIdLog As %Integer) As %DynamicObject
    {
        #Dim exception            As %Exception.General    = ""
        #Dim entry                As Treinamento.Data.LogMensagem
        #Dim jsonObject           As %DynamicObject
        
        Try
        {
            Set jsonObject = {}
        
            Set entry = ..%OpenId(pIdLog)
            
            If $IsObject(entry) {
                Set jsonObject.id             = pIdLog
                Set jsonObject.metodo         = entry.Metodo
                Set jsonObject.classe         = entry.Classe
                Set jsonObject.inicio         = entry.Inicio
                Set jsonObject.fim            = entry.Fim
                Set jsonObject.status         = entry.Status
                Set jsonObject.statusProcesso = entry.StatusProcesso
            }
        }

        Catch(exception) 
        {
            Throw exception
        }
        
        Return jsonObject
    }

    ClassMethod ConsultaLogPaginacaoJSON(pStatus As %Boolean, pLastId As %Integer, pPageSize As %Integer, pDataFim As %String) As %DynamicObject
    {
        #Dim statusCode              As %Status               = $$$OK
        #Dim exception               As %Exception.General    = ""
        #Dim SQL                     As %String
        #Dim statement               As %SQL.Statement
        #Dim resultSet               As %SQL.StatementResult
        #Dim jsonResultado           As %DynamicObject
        #Dim jsonArrayLogs           As %DynamicArray
        #Dim totalRegistros          As %Integer
        #Dim proximoLastId           As %Integer
                
        Try
        {
            Set jsonResultado = {}
            Set jsonArrayLogs = []
            
            If (pPageSize <= 0) Set pPageSize = 10
            
            Set SQL = "SELECT ID, Metodo, Classe, Inicio, Fim, Status, StatusProcesso " _
                      "FROM Treinamento.Data.LogMensagem " _
                      "WHERE Status = ? "
            
            If (pLastId > 0) {
                Set SQL = SQL _ "AND ID < ? "
            }
            
            If (pDataFim '= "") {
                Set SQL = SQL _ "AND Inicio <= ? "
            }
            
            Set SQL = SQL _ "ORDER BY ID DESC LIMIT ?"
           
            Set statement = ##class(%SQL.Statement).%New()
            Set statusCode = statement.%Prepare(SQL)
            If $$$ISERR(statusCode) Throw ##class(%Exception.StatusException).CreateFromStatus(statusCode)
            
            
            If (pLastId > 0) && (pDataFim '= "") 
            {
                Set resultSet = statement.%Execute(pStatus, pLastId, pDataFim, pPageSize)
            } 
            Elseif (pLastId > 0) 
            {
                Set resultSet = statement.%Execute(pStatus, pLastId, pPageSize)
            } 
            Elseif (pDataFim '= "") 
            {
                Set resultSet = statement.%Execute(pStatus, pDataFim, pPageSize)
            } 
            Else 
            {
                Set resultSet = statement.%Execute(pStatus, pPageSize)
            }

            While (resultSet.%Next())
            {
                Set totalRegistros = totalRegistros + 1
                
                Set proximoLastId = resultSet.%Get("ID")
                
                Set jsonItem = {}
                Set jsonItem.id             = proximoLastId
                Set jsonItem.metodo         = resultSet.%Get("Metodo")
                Set jsonItem.classe         = resultSet.%Get("Classe")
                Set jsonItem.inicio         = resultSet.%Get("Inicio")
                Set jsonItem.fim            = resultSet.%Get("Fim")
                Set jsonItem.status         = resultSet.%Get("Status")
                Set jsonItem.statusProcesso = resultSet.%Get("StatusProcesso")
                
                Do jsonArrayLogs.%Push(jsonItem)
            }
            
            Set jsonResultado.logs            = jsonArrayLogs
            Set jsonResultado.totalRetornados = totalRegistros
            
            If (totalRegistros < pPageSize) {
                Set jsonResultado.proximoLastId = 0
            } Else {
                Set jsonResultado.proximoLastId = proximoLastId
            }
        }
        Catch(exception) 
        {
            Throw exception
        }
        
        Return jsonResultado
    }

Storage Default
{
<Data name="LogMensagemDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Metodo</Value>
</Value>
<Value name="3">
<Value>Classe</Value>
</Value>
<Value name="4">
<Value>Inicio</Value>
</Value>
<Value name="5">
<Value>Fim</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>StatusProcesso</Value>
</Value>
<Value name="8">
<Value>Listalog</Value>
</Value>
</Data>
<DataLocation>^Treinamento.Data.LogMensagemD</DataLocation>
<DefaultData>LogMensagemDefaultData</DefaultData>
<IdLocation>^Treinamento.Data.LogMensagemD</IdLocation>
<IndexLocation>^Treinamento.Data.LogMensagemI</IndexLocation>
<StreamLocation>^Treinamento.Data.LogMensagemS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

