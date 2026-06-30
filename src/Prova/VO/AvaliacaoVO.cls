Class Prova.VO.AvaliacaoVO Extends (%SerialObject, %XML.Adaptor)
{
    Property CodigoCandidato As %Integer;
    Property NomeCandidato As %String;
    Property NomeDisciplina As %String;
    Property Tipo As %String;
    Property Nota As %Integer;
    Property Resultado As %String;

Storage Default
{
<Data name="AvaliacaoVOState">
<Value name="1">
<Value>CodigoCandidato</Value>
</Value>
<Value name="2">
<Value>NomeCandidato</Value>
</Value>
<Value name="3">
<Value>NomeDisciplina</Value>
</Value>
<Value name="4">
<Value>Tipo</Value>
</Value>
<Value name="5">
<Value>Nota</Value>
</Value>
<Value name="6">
<Value>Resultado</Value>
</Value>
</Data>
<State>AvaliacaoVOState</State>
<StreamLocation>^Prova.VO.AvaliacaoVOS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
