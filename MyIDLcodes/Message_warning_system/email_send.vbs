Const ForReading = 1, ForWriting = 2, ForAppending = 8
Dim fso, f
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.OpenTextFile("message.txt", ForReading)
BodyText = f.ReadAll


 Set Msg = CreateObject("CDO.Message")
 With Msg
 
 .To = "zuccap@tcd.ie"
 .From = "notifications@rsto.ie"
 .Subject = "System Status Report"
 .TextBody = BodyText
 .Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "go.tcd.ie"
 .Configuration.Fields.Update
 .Send
 
End With

 Set Msg = CreateObject("CDO.Message")
With Msg
 
 .To = "peter.gallagher@tcd.ie"
 .From = "notifications@rsto.ie"
 .Subject = "System Status Report"
 .TextBody = BodyText
 .Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "go.tcd.ie"
 .Configuration.Fields.Update
 .Send
 
End With

 Set Msg = CreateObject("CDO.Message")
With Msg
 
 .To = "pmcculey@tcd.ie"
 .From = "notifications@rsto.ie"
 .Subject = "System Status Report"
 .TextBody = BodyText
 .Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "go.tcd.ie"
 .Configuration.Fields.Update
 .Send
 
End With

 Set Msg = CreateObject("CDO.Message")
With Msg
 
 .To = "morosand@tcd.ie"
 .From = "notifications@rsto.ie"
 .Subject = "System Status Report"
 .TextBody = BodyText
 .Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "go.tcd.ie"
 .Configuration.Fields.Update
 .Send
 
End With

Set Msg = CreateObject("CDO.Message")
With Msg
 
 .To = "eoincarley@gmail.com"
 .From = "notifications@rsto.ie"
 .Subject = "System Status Report"
 .TextBody = BodyText
 .Send
 
End With


 
