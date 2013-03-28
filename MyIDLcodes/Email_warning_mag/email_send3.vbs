 Set Msg = CreateObject("CDO.Message")
 With Msg
 
 .To = "morosand@tcd.ie"
 .From = "notifications@rsto.ie"
 .Subject = "System status report"
 .TextBody = "The magnetometer stopped logging data..." 
 .Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "go.tcd.ie"
 .Configuration.Fields.Update
 .Send
 
End With

 Set Msg = CreateObject("CDO.Message")
 With Msg
 
 .To = "pmcculey@tcd.ie"
 .From = "notifications@rsto.ie"
 .Subject = "System status report"
 .TextBody = "The magnetometer stopped logging data..." 
 .Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "go.tcd.ie"
 .Configuration.Fields.Update
 .Send
 
End With

 Set Msg = CreateObject("CDO.Message")
 With Msg
 
 .To = "zuccap@tcd.ie"
 .From = "notifications@rsto.ie"
 .Subject = "System status report"
 .TextBody = "The magnetometer stopped logging data..." 
 .Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "go.tcd.ie"
 .Configuration.Fields.Update
 .Send
 
End With