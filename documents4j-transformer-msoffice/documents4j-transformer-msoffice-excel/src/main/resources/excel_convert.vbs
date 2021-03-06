' See http://msdn.microsoft.com/en-us/library/bb243311%28v=office.12%29.aspx
Const WdExportFormatPDF = 17
Const MagicFormatPDF = 999
Const HtmFormat = 44

Dim arguments
Set arguments = WScript.Arguments

Function Zip(Outfile)
  'This script is provided under the Creative Commons license located
  'at http://creativecommons.org/licenses/by-nc/2.5/ . It may not
  'be used for commercial purposes with out the expressed written consent
  'of NateRice.com
	Dim outputfilename
	Dim outputfoldername
	Dim outputzipfile
  Set oFSO = WScript.CreateObject("Scripting.FileSystemObject")
  Set oShell = WScript.CreateObject("Wscript.Shell")

  '--------Find Working Directory--------
  aScriptFilename = Split(Wscript.ScriptFullName, "\")
  sScriptFilename = aScriptFileName(Ubound(aScriptFilename))
  sWorkingDirectory = Replace(Wscript.ScriptFullName, sScriptFilename, "")
  '--------------------------------------

  '-------Ensure we can find 7z.exe------
  If oFSO.FileExists(sWorkingDirectory & "\" & "7z.exe") Then
    s7zLocation = ""
  ElseIf oFSO.FileExists("C:\Program Files\7-Zip\7z.exe") Then
    s7zLocation = "C:\Program Files\7-Zip\"
  Else
    Zip = "Error: Couldn't find 7z.exe"
    Exit Function
  End If
  '--------------------------------------
  outputfilename =   """" & Outfile &".htm" & """"
  outputfoldername = """" & Outfile & ".files" & """"
  outputzipfile = """" &Outfile &".zip" & """"
  oShell.Run """" & s7zLocation & "7z.exe"" a  " & outputzipfile &" " _
  &outputfoldername&" "& outputfilename, 0, True

  
  If oFSO.FileExists(Outfile &".htm") Then
  	oFSO.DeleteFile (Outfile &".htm")
  End IF
  If oFSO.FolderExists(Outfile & ".files") Then 
		oFSO.DeleteFolder(Outfile & ".files")
	END IF
	oFSO.MoveFile Outfile &".zip",Outfile &".htm"
	
  If oFSO.FileExists(Outfile) Then
    Zip = 1
  Else
    Zip = "Error: Archive Creation Failed."
  End If
End Function

' Transforms a file using MS Excel into the given format.
Function ConvertFile( inputFile, outputFile, formatEnumeration )

  Dim fileSystemObject
  Dim excelApplication
  Dim excelDocument

  ' Get the running instance of MS Excel. If Excel is not running, exit the conversion.
  On Error Resume Next
  Set excelApplication = GetObject(, "Excel.Application")
  If Err <> 0 Then
    WScript.Quit -6
  End If
  On Error GoTo 0

  ' Find the source file on the file system.
  Set fileSystemObject = CreateObject("Scripting.FileSystemObject")
  inputFile = fileSystemObject.GetAbsolutePathName(inputFile)

  
  ' Convert the source file only if it exists.
  If fileSystemObject.FileExists(inputFile) Then

    ' Attempt to open the source document.
    On Error Resume Next
    Set excelDocument = excelApplication.Workbooks.Open(inputFile, , True, , , , , , , , , , , , 2)
    If Err <> 0 Then
        WScript.Quit -2
    End If
    On Error GoTo 0

    ' Convert: See http://msdn2.microsoft.com/en-us/library/bb221597.aspx
    On Error Resume Next
    If formatEnumeration = MagicFormatPDF Then
      excelDocument.ExportAsFixedFormat xlTypePDF, outputFile
      excelDocument.Close False
	ElseIf formatEnumeration = HtmFormat Then     	
	   	excelDocument.WebOptions.RelyOnCSS = True
    	excelDocument.WebOptions.OrganizeInFolder = True
    	excelDocument.WebOptions.UseLongFileNames = True
    	excelDocument.WebOptions.DownloadComponents = False
    	excelDocument.WebOptions.RelyOnVML = False
    	excelDocument.WebOptions.AllowPNG = True
    	excelDocument.WebOptions.ScreenSize = 4
    	excelDocument.WebOptions.PixelsPerInch = 96
    	excelDocument.WebOptions.Encoding = 949
    	excelApplication.Application.DefaultWebOptions.SaveHiddenData = True
    	excelApplication.Application.DefaultWebOptions.LoadPictures = True
    	excelApplication.Application.DefaultWebOptions.UpdateLinksOnSave = True
    	excelApplication.Application.DefaultWebOptions.CheckIfOfficeIsHTMLEditor = True
    	excelApplication.Application.DefaultWebOptions.AlwaysSaveInDefaultEncoding = False
    	excelApplication.Application.DefaultWebOptions.SaveNewWebPagesAsWebArchives = True
      	excelDocument.SaveAs outputFile, formatEnumeration
      	excelDocument.Close False
      	Call Zip(outputFile)   
    Else
      excelDocument.SaveAs outputFile, formatEnumeration
      excelDocument.Close False
    End If

    ' Close the source document.
    
    If Err <> 0 Then
        WScript.Quit -3
    End If
    On Error GoTo 0

    ' Signal that the conversion was successful.
    WScript.Quit 2

  Else

    ' Files does not exist, could not convert
    WScript.Quit -4

  End If

End Function

' Execute the script.
Call ConvertFile( WScript.Arguments.Unnamed.Item(0), WScript.Arguments.Unnamed.Item(1), CInt(WScript.Arguments.Unnamed.Item(2)) )
