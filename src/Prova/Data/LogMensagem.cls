Class Prova.Data.LogMensagem Extends (%Persistent, %XML.Adaptor)
{
    Property Metodo As %String(MAXLEN="") [SqlColumnNumber = 2];
    Property Classe As %String(MAXLEN="") [SqlColumnNumber = 3];
    Property Inicio As %String [SqlColumnNumber = 4];
    Property Fim As %String [SqlColumnNumber = 5];
    Property Status As %String [SqlColumnNumber = 6];
    Property StatusProcesso As %String [SqlColumnNumber = 7];
    Property ListaLog As list of Prova.VO.LogMensagem [SqlColumnNumber = 8];

    ClassMethod CriarEntrada(pMetodo As %String, pClasse As %String, pStatusCode As %String) As Prova.Data.LogMensagem
    {
        Set entry                   = ..%New()
        Set entry.Metodo            = pMetodo
        Set entry.Classe            = pClasse
        Set entry.Inicio            = $ZDATETIME($HOROLOG, 4)
        Set entry.Status            = pStatusCode
        Set entry.StatusProcesso    = ""
        Set sc                      = entry.%Save()

        If $$$ISERR(sc)
        {
            Throw ##class(%Exception.General).%New("Erro ao criar o registro de log")
        }

        Return entry
    }

    ClassMethod Finalizar(pIdLog As %Integer, pStatusProcesso As %String, pStatusCode As %String) As Prova.Data.LogMensagem
    {
        Set entry = ..%OpenId(pIdLog)

        If '$IsObject(entry)
        {
            Throw ##class(%Exception.General).%New("Log não encontrado")
        }

        Set entry.Fim               = $ZDATETIME($HOROLOG, 4)
        Set entry.StatusProcesso    = pStatusProcesso
        Set entry.Status            = pStatusCode
        Set sc                      = entry.%Save()

        If $$$ISERR(sc)
        {
            Throw ##class(%Exception.General).%New("Erro ao finalizar o registro de log")
        }

        Return entry
    }

    ClassMethod ConsultaLog(pStatus As %String, pDataInicio As %String, pDataFim As %String) As %DynamicObject
    {
        Set resultado   = ##class(%DynamicObject).%New()
        Set logs        = ##class(%DynamicArray).%New()

        Try
        {
            Set sql = "SELECT ID, Metodo, Classe, Inicio, Fim, Status, StatusProcesso FROM Prova_Data.LogMensagem WHERE 1=1"

            If (pStatus '= "")
            {
                Set sql = sql _ " AND Status = '" _ pStatus _ "'"
            }

            If (pDataInicio '= "")
            {
                Set sql = sql _ " AND Inicio >= '" _ pDataInicio _ "'"
            }

            If (pDataFim '= "")
            {
                Set sql = sql _ " AND Fim <= '" _ pDataFim _ "'"
            }

            Set sql     = sql _ " ORDER BY ID ASC"

            Set stmt    = ##class(%SQL.Statement).%New()
            Set sc      = stmt.%Prepare(sql)
            If $$$ISERR(sc)
            {
                Set resultado.Erro = $System.Status.GetErrorText(sc)
                Return resultado
            }

            Set rset = stmt.%Execute()

            While rset.%Next()
            {
                Set jsonItem                = ##class(%DynamicObject).%New()
                Set jsonItem.ID             = rset.%Get("ID")
                Set jsonItem.Metodo         = rset.%Get("Metodo")
                Set jsonItem.Classe         = rset.%Get("Classe")
                Set jsonItem.Inicio         = rset.%Get("Inicio")
                Set jsonItem.Fim            = rset.%Get("Fim")
                Set jsonItem.Status         = rset.%Get("Status")
                Set jsonItem.StatusProcesso = rset.%Get("StatusProcesso")
                Do logs.%Push(jsonItem)
            }

            Set resultado.Logs              = logs
            Set resultado.TotalRegistros    = logs.%Size()
        }
        Catch ex
        {
            Set resultado.Erro = "Erro ao consultar log: " _ ex.AsSystemError()
        }

        Return resultado
    }

    ClassMethod ConsultaLogPaginacaoJSON(pStatus As %String, pLastId As %Integer, pPageSize As %Integer, pDataFim As %String) As %DynamicObject
    {
        Set jsonResultado   = ##class(%DynamicObject).%New()
        Set jsonArray       = ##class(%DynamicArray).%New()

        Try
        {
            Set sql = "SELECT TOP " _ pPageSize _ " ID, Metodo, Classe, Inicio, Fim, Status, StatusProcesso FROM Prova_Data.LogMensagem WHERE 1=1"

            If (pStatus '= "")
            {
                Set sql = sql _ " AND Status = '" _ pStatus _ "'"
            }

            If (pLastId > 0)
            {
                Set sql = sql _ " AND ID > " _ pLastId
            }

            If (pDataFim '= "")
            {
                Set sql = sql _ " AND Fim <= '" _ pDataFim _ "'"
            }

            Set sql     = sql _ " ORDER BY ID ASC"

            Set stmt    = ##class(%SQL.Statement).%New()
            Set sc      = stmt.%Prepare(sql)
            If $$$ISERR(sc)
            {
                Set jsonResultado.Erro = $System.Status.GetErrorText(sc)
                Return jsonResultado
            }

            Set rset                = stmt.%Execute()
            Set ultimoIdProcessado  = pLastId

            While rset.%Next()
            {
                Set jsonItem                    = ##class(%DynamicObject).%New()
                Set ultimoIdProcessado          = rset.%Get("ID")

                Set jsonItem.ID                 = ultimoIdProcessado
                Set jsonItem.Metodo             = rset.%Get("Metodo")
                Set jsonItem.Classe             = rset.%Get("Classe")
                Set jsonItem.Inicio             = rset.%Get("Inicio")
                Set jsonItem.Fim                = rset.%Get("Fim")
                Set jsonItem.Status             = rset.%Get("Status")
                Set jsonItem.StatusProcesso     = rset.%Get("StatusProcesso")

                Do jsonArray.%Push(jsonItem)
            }

            Set jsonResultado.TotalRegistros    = jsonArray.%Size()
            Set jsonResultado.ProximoLastId     = ultimoIdProcessado
            Set jsonResultado.Logs              = jsonArray
        }
        Catch ex
        {
            Set jsonResultado.Erro = "Falha na paginação: " _ ex.AsSystemError()
        }

        Return jsonResultado
    }

    ClassMethod BuscarLogPorIdJSON(pId As %Integer) As %DynamicObject
    {
        Set jsonResponse = ##class(%DynamicObject).%New()

        Try
        {
            Set log = ##class(Prova.Data.LogMensagem).%OpenId(pId)

            If $IsObject(log)
            {
                Set jsonResponse.ID             = pId
                Set jsonResponse.Metodo         = log.Metodo
                Set jsonResponse.Classe         = log.Classe
                Set jsonResponse.Inicio         = log.Inicio
                Set jsonResponse.Fim            = log.Fim
                Set jsonResponse.Status         = log.Status
                Set jsonResponse.StatusProcesso = log.StatusProcesso
            }
        }
        Catch ex
        {
            Set jsonResponse.Erro = "Erro interno ao processar a busca: " _ ex.AsSystemError()
        }

        Return jsonResponse
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
<Value>ListaLog</Value>
</Value>
</Data>
<DataLocation>^Prova.Data.LogMensagemD</DataLocation>
<DefaultData>LogMensagemDefaultData</DefaultData>
<IdLocation>^Prova.Data.LogMensagemD</IdLocation>
<IndexLocation>^Prova.Data.LogMensagemI</IndexLocation>
<StreamLocation>^Prova.Data.LogMensagemS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
