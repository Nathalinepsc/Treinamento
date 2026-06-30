Class Prova.Data.Candidato Extends (%Persistent, %XML.Adaptor)
{
    Property Nome As %String [SqlColumnNumber = 2];
    Property Idade As %Integer [SqlColumnNumber = 3];
    Property Sexo As %String [SqlColumnNumber = 4];
    Property CodigoCandidato As %Integer [SqlColumnNumber = 5];

    Relationship Avaliacoes As Prova.Data.Avaliacao [ Cardinality = many, Inverse = CodigoCandidato ];
    Relationship Inscricoes As Prova.Data.CandidatoCurso [ Cardinality = many, Inverse = Candidato ];

    ClassMethod ConsultaCandidato(pCodigoCandidato As %Integer) As %Status
    {
        Set sc = $$$OK

        Try
        {
            Set candidato = ##class(Prova.Data.Candidato).%OpenId(pCodigoCandidato)
            If '$IsObject(candidato)
            {
                Write "Candidato não encontrado.", !
                Return sc
            }

            Write "Candidato: ", candidato.Nome, !
            Set iterator = candidato.Avaliacoes.GetIterator()

            While iterator.%GetNext(.key, .value)
            {
                If $IsObject(value)
                {
                    Write value.NomeDisciplina, " - ", ..ObterSituacaoAvaliacao(value.Tipo, value.Nota), !
                }
            }
        }
        Catch ex
        {
            Set sc = ex.AsStatus()
            Write "Erro ao consultar candidato: ", $System.Status.GetErrorText(sc), !
        }

        Return sc
    }

    Method VerificaAprovacao() As %String
    {
        Set resultado = ""
        Set iterator = ..Avaliacoes.GetIterator()

        While iterator.%GetNext(.key, .value)
        {
            If $IsObject(value)
            {
                Set linha = value.NomeDisciplina _ " - " _ ..ObterSituacaoAvaliacao(value.Tipo, value.Nota)

                If (resultado '= "")
                {
                    Set resultado = resultado _ $Char(10)
                }
                Set resultado = resultado _ linha
            }
        }

        Return resultado
    }

    ClassMethod AnalisaNome(pNomeCompleto As %String) As %Status
    {
        Set sc = $$$OK

        Try
        {
            Set nomeSemEspacos = $Translate(pNomeCompleto, " ", "")
            Write "Quantidade de caracteres: ", $Length(nomeSemEspacos), !
            Write "Nome com separadores: ", $Replace(pNomeCompleto, " ", "|"), !
        }
        Catch ex
        {
            Set sc = ex.AsStatus()
            Write "Erro ao analisar nome: ", $System.Status.GetErrorText(sc), !
        }

        Return sc
    }

    ClassMethod AnalisaDataNascimento(pDataNascimento As %String) As %Status
    {
        Set sc = $$$OK

        Try
        {
            Set horolog = $ZDATEH(pDataNascimento, 4)
            Set dataIslamica = $ZDATE(horolog, 18)
            Set mesIslamico = $Piece(dataIslamica, " ", 2)

            Write "Data em $Horolog: ", horolog, !
            Write "Data em formato islâmico: ", dataIslamica, !
            Write "Nome do mês islâmico: ", mesIslamico, !
        }
        Catch ex
        {
            Set sc = ex.AsStatus()
            Write "Erro ao analisar data: ", $System.Status.GetErrorText(sc), !
        }

        Return sc
    }

    ClassMethod BuscarCandidatoPorIdJSON(pCodigoCandidato As %Integer) As %DynamicObject
    {
        Set jsonResponse = ##class(%DynamicObject).%New()

        Try
        {
            Set candidato = ##class(Prova.Data.Candidato).%OpenId(pCodigoCandidato)

            If '$IsObject(candidato)
            {
                Set jsonResponse.Erro = "Candidato não encontrado."
                Return jsonResponse
            }

            Set jsonResponse.ID = candidato.%Id()
            Set jsonResponse.Nome = candidato.Nome
            Set jsonResponse.Idade = candidato.Idade
            Set jsonResponse.Sexo = candidato.Sexo
            Set jsonResponse.CodigoCandidato = candidato.CodigoCandidato
            Set avaliacoes = ##class(%DynamicArray).%New()
            Set iterator = candidato.Avaliacoes.GetIterator()

            While iterator.%GetNext(.key, .value)
            {
                If $IsObject(value)
                {
                    Set jsonAvaliacao = ##class(%DynamicObject).%New()
                    Set jsonAvaliacao.ID = value.%Id()
                    Set jsonAvaliacao.NomeDisciplina = value.NomeDisciplina
                    Set jsonAvaliacao.Tipo = value.Tipo
                    Set jsonAvaliacao.Nota = value.Nota
                    Set jsonAvaliacao.Resultado = ..ObterSituacaoAvaliacao(value.Tipo, value.Nota)
                    Do avaliacoes.%Push(jsonAvaliacao)
                }
            }

            Set jsonResponse.Avaliacoes = avaliacoes
        }
        Catch ex
        {
            Set jsonResponse.Erro = "Erro interno ao processar a busca: " _ ex.AsSystemError()
        }

        Return jsonResponse
    }

    ClassMethod ConsultaCandidatoPaginacaoJSON(pNomeCandidato As %String = "", LastId As %Integer = 0, PageSize As %Integer = 10, Sexo As %String = "") As %DynamicObject
    {
        Set jsonResultado = ##class(%DynamicObject).%New()
        Set jsonArray = ##class(%DynamicArray).%New()

        Try
        {
            Set sql = "SELECT TOP " _ PageSize _ " ID, Nome, Idade, Sexo, CodigoCandidato FROM Prova_Data.Candidato WHERE 1=1"

            If (pNomeCandidato '= "")
            {
                Set sql = sql _ " AND Nome %LIKE '%" _ pNomeCandidato _ "%'"
            }

            If (LastId > 0)
            {
                Set sql = sql _ " AND ID > " _ LastId
            }

            If (Sexo '= "")
            {
                Set sql = sql _ " AND Sexo = '" _ Sexo _ "'"
            }

            Set sql = sql _ " ORDER BY ID ASC"

            Set stmt = ##class(%SQL.Statement).%New()
            Set sc = stmt.%Prepare(sql)
            If $$$ISERR(sc)
            {
                Set jsonResultado.Erro = $System.Status.GetErrorText(sc)
                Return jsonResultado
            }

            Set rset = stmt.%Execute()
            Set ultimoIdProcessado = LastId

            While rset.%Next()
            {
                Set candidatoId = rset.%Get("ID")
                Set ultimoIdProcessado = candidatoId

                Set candidato = ##class(Prova.Data.Candidato).%OpenId(candidatoId)

                If $IsObject(candidato)
                {
                    Set jsonItem = ##class(%DynamicObject).%New()
                    Set jsonItem.ID = candidato.%Id()
                    Set jsonItem.Nome = candidato.Nome
                    Set jsonItem.Idade = candidato.Idade
                    Set jsonItem.Sexo = candidato.Sexo
                    Set jsonItem.CodigoCandidato = candidato.CodigoCandidato
                    Set avaliacoes = ##class(%DynamicArray).%New()
                    Set iterator = candidato.Avaliacoes.GetIterator()

                    While iterator.%GetNext(.key, .value)
                    {
                        If $IsObject(value)
                        {
                            Set jsonAvaliacao = ##class(%DynamicObject).%New()
                            Set jsonAvaliacao.NomeDisciplina = value.NomeDisciplina
                            Set jsonAvaliacao.Tipo = value.Tipo
                            Set jsonAvaliacao.Nota = value.Nota
                            Set jsonAvaliacao.Resultado = ..ObterSituacaoAvaliacao(value.Tipo, value.Nota)

                            Do avaliacoes.%Push(jsonAvaliacao)
                        }
                    }

                    Set jsonItem.Avaliacoes = avaliacoes
                    Do jsonArray.%Push(jsonItem)
                }
            }

            Set jsonResultado.TotalRegistros = jsonArray.%Size()
            Set jsonResultado.ProximoLastId = ultimoIdProcessado
            Set jsonResultado.Candidatos = jsonArray
        }
        Catch ex
        {
            Set jsonResultado.Erro = "Falha na paginação: " _ ex.AsSystemError()
        }

        Return jsonResultado
    }

    ClassMethod ObterSituacaoAvaliacao(pTipo As %String, pNota As %Integer) As %String
    {
        If (pTipo = "Teorica")
        {
            If (pNota >= 6)
            {
                Return "APROVADO"
            }
            Return "REPROVADO"
        }

        If (pTipo = "Pratica")
        {
            If (pNota >= 7)
            {
                Return "APROVADO"
            }
            Return "REPROVADO"
        }

        Return "SEM CLASSIFICAÇÃO"
    }

Storage Default
{
<Data name="CandidatoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Nome</Value>
</Value>
<Value name="3">
<Value>Idade</Value>
</Value>
<Value name="4">
<Value>Sexo</Value>
</Value>
<Value name="5">
<Value>CodigoCandidato</Value>
</Value>
<Value name="6">
<Value>Inscricoes</Value>
</Value>
</Data>
<DataLocation>^Prova.Data.CandidatoD</DataLocation>
<DefaultData>CandidatoDefaultData</DefaultData>
<IdLocation>^Prova.Data.CandidatoD</IdLocation>
<IndexLocation>^Prova.Data.CandidatoI</IndexLocation>
<StreamLocation>^Prova.Data.CandidatoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
