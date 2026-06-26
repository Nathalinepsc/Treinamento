Class Prova.Data.Candidato Extends (%Persistent, %XML.Adaptor)
{
    Property Nome As %String [SqlColumnNumber = 2];
    Property Idade As %Integer [SqlColumnNumber = 3];
    Property Sexo As %String [SqlColumnNumber = 4];
    Property CodigoCandidato As %Integer [SqlColumnNumber = 5];

    Relationship Avaliacoes As Prova.Data.Avaliacao [ Cardinality = many, Inverse = CodigoCandidato ];

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
</Data>
<DataLocation>^Prova.Data.CandidatoD</DataLocation>
<DefaultData>CandidatoDefaultData</DefaultData>
<IdLocation>^Prova.Data.CandidatoD</IdLocation>
<IndexLocation>^Prova.Data.CandidatoI</IndexLocation>
<StreamLocation>^Prova.Data.CandidatoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
