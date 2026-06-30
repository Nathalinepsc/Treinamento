Class Prova.Data.Curso Extends (%Persistent, %XML.Adaptor)
{
    Property Nome As %String [SqlColumnNumber = 2];
    Property Descricao As %String [SqlColumnNumber = 3];
    Property CodigoCurso As %Integer [SqlColumnNumber = 4];

    Relationship Inscricoes As Prova.Data.CandidatoCurso [ Cardinality = many, Inverse = Curso ];


Storage Default
{
<Data name="CursoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Nome</Value>
</Value>
<Value name="3">
<Value>Descricao</Value>
</Value>
<Value name="4">
<Value>CodigoCurso</Value>
</Value>
</Data>
<DataLocation>^Prova.Data.CursoD</DataLocation>
<DefaultData>CursoDefaultData</DefaultData>
<IdLocation>^Prova.Data.CursoD</IdLocation>
<IndexLocation>^Prova.Data.CursoI</IndexLocation>
<StreamLocation>^Prova.Data.CursoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
