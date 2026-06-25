Class Treinamento.VO.LogMensagem Extends (%SerialObject, %XML.Adaptor)
{
    Property Metodo As %String(MAXLEN="") [SqlColumnNumber = 2];
    Property Classe As %String(MAXLEN="") [SqlColumnNumber = 3];
    Property Inicio As %String [ SqlColumnNumber = 4];
    Property Fim As %String [ SqlColumnNumber = 5 ];
    Property Status As %Boolean [ SqlColumnNumber = 6 ];
    Property StatusProcesso As %String [ SqlColumnNumber = 7 ];
    Property Listalog As list of Treinamento.VO.LogMensagem;

Storage Default
{
<Data name="LogMensagemState">
<Value name="1">
<Value>Metodo</Value>
</Value>
<Value name="2">
<Value>Classe</Value>
</Value>
<Value name="3">
<Value>Inicio</Value>
</Value>
<Value name="4">
<Value>Fim</Value>
</Value>
<Value name="5">
<Value>Status</Value>
</Value>
<Value name="6">
<Value>StatusProcesso</Value>
</Value>
<Value name="7">
<Value>Listalog</Value>
</Value>
</Data>
<State>LogMensagemState</State>
<StreamLocation>^Treinamento.VO.LogMensagemS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
