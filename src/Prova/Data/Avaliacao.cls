Class Prova.Data.Avaliacao Extends (%Persistent, %XML.Adaptor)
{
    Property NomeDisciplina As %String [SqlColumnNumber = 3];
    Property Tipo As %String [SqlColumnNumber = 4];
    Property Nota As %Integer [SqlColumnNumber = 5];

    Relationship CodigoCandidato As Prova.Data.Candidato [ Cardinality = one, Inverse = Avaliacoes ];

    ClassMethod ConsultaCandidato(CodigoCandidato As Avaliacao) As %Status
    {
        Set sc = $$$OK
        // do something
        Return sc
    }

    
    Method VerificaAprovacao() As %Status
    {
        Set sc = $$$OK
        // do something
        Return sc
    }

    ClassMethod AnalisaNome() As %Status
    {
        Set sc = $$$OK
        // do something
        Return sc
    }

    ClassMethod AnalisaDataNascimento() As %Status
    {
        Set sc = $$$OK
        // do something
        Return sc
    }

    ClassMethod BuscarCandidatoPorIdJSON(CodigoCandidato) As %Status
    {
        Set sc = $$$OK
        // do something
        Return sc
    }

    ClassMethod ConsultaCandidatoPaginacaoJSON(NomeCandidato, LastId, PageSize, Sexo) As %Status
    {
        Set sc = $$$OK
        // do something
        Return sc
    }

    
Storage Default
{
<Data name="AvaliacaoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>NomeDisciplina</Value>
</Value>
<Value name="3">
<Value>Tipo</Value>
</Value>
<Value name="4">
<Value>Nota</Value>
</Value>
<Value name="5">
<Value>CodigoCandidato</Value>
</Value>
</Data>
<DataLocation>^Prova.Data.AvaliacaoD</DataLocation>
<DefaultData>AvaliacaoDefaultData</DefaultData>
<IdLocation>^Prova.Data.AvaliacaoD</IdLocation>
<IndexLocation>^Prova.Data.AvaliacaoI</IndexLocation>
<StreamLocation>^Prova.Data.AvaliacaoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
