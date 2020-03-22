codeunit 50060 "Web Management"
{
    trigger OnRun()
    begin

    end;

    procedure CreateItemCreationRequest()
    var
        EnvNameSpaceLbl: Label 'http://schemas.xmlsoap.org/soap/envelope/';
        BarcodeNameSpaceLbl: Label 'http://tempuri.org/';
    begin
        Clear(XmlTextG);
        WebServiceSetupG.Get();
        WebServiceSetupG.TestField("Farfetch Item Creation");
        WebServiceTemplateG.Get(WebServiceSetupG."Farfetch Item Creation");
        XmlDocumentG := XmlDocument.Create();
        XmlDomMgmtG.AddDeclaration(XmlDocumentG, '1.0', 'UTF-8', 'no');
        XmlDomMgmtG.AddRootElement(XmlDocumentG, 'Envelope', EnvNameSpaceLbl, EnvelopeXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Body', '', EnvNameSpaceLbl, EnvelopeXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'BarcodeProcessAbsoluteQuantity', '', BarcodeNameSpaceLbl, EnvelopeXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Key', WebServiceTemplateG.Password, BarcodeNameSpaceLbl, TempXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Barcode', '263301701-OS', BarcodeNameSpaceLbl, TempXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'absoluteQuantity', '10', BarcodeNameSpaceLbl, TempXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'ErrMsg', '', BarcodeNameSpaceLbl, TempXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'IsAdjustment', 'false', BarcodeNameSpaceLbl, TempXmlNodeG);
        XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'currentStock', '1', BarcodeNameSpaceLbl, TempXmlNodeG);
        XmlDocumentG.WriteTo(XmlTextG);
        //PostItemCreationRequest2(TransactionLogG.InsertTransactionLog(DirectionG::"Outgoing Request", StatusG::Processed, WebServiceTemplateG."Template Code", 0, XmlTextG), XmlTextG, WebServiceTemplateG.Url, WebServiceTemplateG."Template Code");
        PostItemCreationRequest1(TransactionLogG.InsertTransactionLog(DirectionG::"Outgoing Request", StatusG::Processed, WebServiceTemplateG."Template Code", 0, XmlTextG), XmlTextG, WebServiceTemplateG.Url, WebServiceTemplateG."Template Code");
    end;

    // recommended method
    procedure PostItemCreationRequest1(EntryNoP: BigInteger; XmlTextP: Text; UrlP: Text[250]; TemplateCodeP: Code[20])
    begin
        ContentG.WriteFrom(XmlTextP);
        ContentG.GetHeaders(HeaderG);
        HeaderG.Clear();
        HeaderG.Add('Content-Type', 'text/xml;charset=utf-8');
        HeaderG.Add('SOAPAction', 'http://tempuri.org/BarcodeProcessAbsoluteQuantity');
        RequestG.Content := ContentG;
        RequestG.SetRequestUri(UrlP);
        RequestG.Method := 'POST';
        if ClientG.Send(RequestG, ResponseG) then begin
            if ResponseG.Content().ReadAs(ResponseTextG) then
                // TODO based on the API response to be handled
                TransactionLogG.InsertTransactionLog(DirectionG::"Outgoing Request", StatusG::Processed, TemplateCodeP, 0, ResponseTextG)
            else begin
                TransactionLogG.ModifyStatus(EntryNoP);
                ErrorLogG.InsertErrorlog(EntryNoP, InvalidResErr); // capture other error
            end;
        end else begin
            TransactionLogG.ModifyStatus(EntryNoP);
            ErrorLogG.InsertErrorlog(EntryNoP, FailedCallErr); // timeout or out of service
        end;
    end;

    procedure PostItemCreationRequest2(EntryNoP: BigInteger; XmlTextP: Text; UrlP: Text[250]; TemplateCodeP: Code[20])
    begin
        ClientG.Clear();
        ContentG.WriteFrom(XmlTextP);
        ContentG.GetHeaders(HeaderG);
        HeaderG.Remove('Content-Type');
        HeaderG.Add('Content-Type', 'text/xml;charset=utf-8');
        HeaderG.Add('SOAPAction', 'http://tempuri.org/BarcodeProcessAbsoluteQuantity');
        ClientG.SetBaseAddress(UrlP);
        if ClientG.Post(UrlP, ContentG, ResponseG) then begin
            ResponseG.Content().ReadAs(ResponseTextG);
            TransactionLogG.InsertTransactionLog(DirectionG::"Outgoing Request", StatusG::Processed, TemplateCodeP, 0, ResponseTextG);
        end else begin
            ResponseTextG := 'reason:' + ResponseG.ReasonPhrase() + ' code:' + format(ResponseG.HttpStatusCode()) + ' status:' + format(ResponseG.IsSuccessStatusCode());
            ErrorLogG.InsertErrorlog(EntryNoP, ResponseTextG);
            Message(ResponseTextG);
        end
    end;

    procedure PostWithOauth()
    var
        JsonL: JsonObject;
        RequestL: Text;
        ResponseL: Text;
        ContentL: HttpContent;
        ClientL: HttpClient;
        HeaderL: HttpHeaders;
        HttpResponseL: HttpResponseMessage;
        HttpRequestL: HttpRequestMessage;
        ApiKeyTxt: Label 'OAuth realm="4344065_SB1",oauth_consumer_key="fc5d2e831b5df9aef116c51bb39aaf83",oauth_token="8066463c407d38bc4c10fddf9424ad5e",oauth_signature_method="PLAINTEXT",oauth_nonce="8d8C09a6UfD",oauth_version="1.0",oauth_signature="39250ee648c18636efe54557cf636db0%26b619bfeddb908552cff2403727887934"';
    begin
        JsonL.Add('sku', '3700741500162');
        JsonL.WriteTo(RequestL);

        ContentL.WriteFrom(RequestL);
        ContentL.GetHeaders(HeaderL);
        HeaderL.Clear();
        HeaderL.Add('Content-Type', 'application/json');
        HttpRequestL.Content(ContentL);
        HttpRequestL.GetHeaders(HeaderL);
        HttpRequestL.Method('PUT');
        ClientL.DefaultRequestHeaders().Add('Accept', '*/*');
        ClientL.DefaultRequestHeaders().Add('Authorization', ApiKeyTxt);
        ClientL.Post('https://sandbox.goldenscent.com/api/rest/products/3700741500162', ContentL, HttpResponseL);
        HttpResponseL.Content().ReadAs(ResponseL);
        Message(ResponseL);
    end;

    procedure CreateXml1()
    var
        XmlBufferL: Record "XML Buffer" temporary;
        XmlReaderL: Codeunit "XML Buffer Reader";
        TempBlobL: Codeunit "Temp Blob";
        XmlMgmtL: Codeunit "XML DOM Mgt.";
        XmlTextL: Text;
        InstreamL: InStream;
        XmlDocL: XmlDocument;

    begin
        Clear(XmlBufferL);
        XmlBufferL.DeleteAll();
        XmlBufferL.AddGroupElement('Envelope');
        XmlBufferL.AddNamespace('', 'http://schemas.xmlsoap.org/soap/envelope/');
        XmlBufferL.AddGroupElement('Body');
        XmlBufferL.AddGroupElement('ImportASN');
        XmlBufferL.AddNamespace('', 'http://tempuri.org/');
        XmlBufferL.AddGroupElement('ASN');

        XmlBufferL.AddGroupElement('DataHeader');
        XmlBufferL.AddNamespace('', 'http://schemas.datacontract.org/2004/07/CORP.DXB.LOG.EDI_WS');
        XmlBufferL.AddElement('ClinetSystemRef', '001001');
        XmlBufferL.AddElement('Currency', 'SAR');
        XmlBufferL.AddElement('Facility', 'WMWHSE1');
        XmlBufferL.AddElement('StorerKey', 'Demo');
        XmlBufferL.AddElement('Type', 'Customer Return');
        XmlBufferL.GetParent(); // DataHeader

        XmlBufferL.AddGroupElement('DataLines');
        XmlBufferL.AddNamespace('', 'http://schemas.datacontract.org/2004/07/CORP.DXB.LOG.EDI_WS');
        XmlBufferL.AddGroupElement('ARX_EDI._DataLine_ASN');
        XmlBufferL.AddElement('ExternLineNo', '001001');
        XmlBufferL.AddElement('Notes', 'SAR');
        XmlBufferL.AddElement('Qty', 'WMWHSE1');
        XmlBufferL.AddElement('SKU', 'Demo');
        XmlBufferL.AddElement('UnitCost', 'Customer Return');
        XmlBufferL.GetParent(); // ARX_EDI._DataLine_ASN
        XmlBufferL.GetParent(); // DataLines

        XmlBufferL.AddGroupElement('SSA');
        XmlBufferL.AddNamespace('', 'http://schemas.datacontract.org/2004/07/CORP.DXB.LOG.EDI_W');
        XmlBufferL.AddElement('SSA_Login', 'wsgc');
        XmlBufferL.AddElement('SSA_Password', 'wsgc2020');
        XmlBufferL.GetParent(); // SSA

        XmlBufferL.GetParent(); // ASN
        XmlBufferL.GetParent(); // ImportASN
        XmlBufferL.GetParent(); // Body
        XmlBufferL.GetParent(); // Envelope

        XmlReaderL.SaveToTempBlob(TempBlobL, XmlBufferL);
        TempBlobL.CreateInStream(InstreamL);
        XmlMgmtL.LoadXMLDocumentFromInStream(InstreamL, XmlDocL);
        XmlDocL.WriteTo(XmlTextL);
        Message(XmlTextL);
    end;

    // procedure CreateXml2()
    // var
    //     XmlDomMgmtL: Codeunit "XML DOM Mgt.";
    //     XmlDocumentL: XmlDocument;
    //     EnvelopeXmlNodeL: XmlNode;
    //     lTempXmlNode: XmlNode;
    //     EnvNameSpaceLbl: Label 'http://schemas.xmlsoap.org/soap/envelope/';
    //     BarcodeNameSpaceLbl: Label 'http://tempuri.org/';
    //     HttpClientL: HttpClient;
    //     HttpContentL: HttpContent;
    //     HttpHeaderL: HttpHeaders;
    //     XmlTextL: Text;
    //     HttpResponseL: HttpResponseMessage;
    //     ResponseTextL: Text;
    // begin
    //     XmlDocumentL := XmlDocument.Create();
    //     XmlDomMgmtL.AddDeclaration(XmlDocumentL, '1.0', 'UTF-8', 'no');
    //     XmlDomMgmtL.AddRootElement(XmlDocumentL, 'Envelope', EnvNameSpaceLbl, EnvelopeXmlNodeL);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'Body', '', EnvNameSpaceLbl, EnvelopeXmlNodeL);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'BarcodeProcessAbsoluteQuantity', '', BarcodeNameSpaceLbl, EnvelopeXmlNodeL);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'Key', '', BarcodeNameSpaceLbl, lTempXmlNode);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'Barcode', '263301701-OS', BarcodeNameSpaceLbl, lTempXmlNode);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'absoluteQuantity', '10', BarcodeNameSpaceLbl, lTempXmlNode);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'ErrMsg', '', BarcodeNameSpaceLbl, lTempXmlNode);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'IsAdjustment', 'false', BarcodeNameSpaceLbl, lTempXmlNode);
    //     XmlDomMgmtL.AddElement(EnvelopeXmlNodeL, 'currentStock', '1', BarcodeNameSpaceLbl, lTempXmlNode);
    //     XmlDocumentL.WriteTo(XmlTextL);
    //     HttpClientL.Clear();

    //     HttpContentL.WriteFrom(XmlTextL);
    //     HttpContentL.GetHeaders(HttpHeaderL);
    //     HttpHeaderL.Remove('Content-Type');
    //     HttpHeaderL.Add('Content-Type', 'text/xml;charset=utf-8');
    //     HttpHeaderL.Add('SOAPAction', 'http://tempuri.org/BarcodeProcessAbsoluteQuantity');
    //     HttpClientL.SetBaseAddress('https://rcs02-sales.fftech.info/pub/apistock.asmx');
    //     if HttpClientL.Post('https://rcs02-sales.fftech.info/pub/apistock.asmx', HttpContentL, HttpResponseL) then
    //         HttpResponseL.Content().ReadAs(ResponseTextL)
    //     else
    //         HttpResponseL.Content().ReadAs(ResponseTextL);
    //     Message(ResponseTextL);
    // end;

    // procedure CreateXml3()
    // var
    //     TembBlobL: Codeunit "Temp Blob";
    //     XmlDocumentL: XmlDocument;
    //     XmlDeclarationL: XmlDeclaration;
    //     XmlElementL: XmlElement;
    //     XmlElement2L: XmlElement;
    //     OutStr: OutStream;
    //     InStr: InStream;
    //     FileName: Text;
    // begin

    //     XmlDocumentL := XmlDocument.Create();
    //     XmlDeclarationL := XmlDeclaration.Create('1.0', 'UTF-8', 'no');
    //     XmlDocumentL.SetDeclaration(XmlDeclarationL);

    //     XmlElementL := XmlElement.Create('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');

    //     //XmlElementL.SetAttribute('release', '2.1');
    //     XmlElement2L := XmlElement.Create('FirstName');
    //     XmlElement2L.Add(XmlText.Create('Selva'));
    //     XmlElementL.Add(XmlElement2L);

    //     XmlElement2L := XmlElement.Create('LastName');
    //     XmlElement2L.Add(XmlText.Create('T'));
    //     XmlElementL.Add(XmlElement2L);

    //     XmlDocumentL.Add(XmlElementL);
    //     XmlDocumentL.WriteTo(FileName);
    //     Message(FileName);
    //     // TembBlobL.CreateOutStream(OutStr);
    //     // XmlDocumentL.WriteTo(OutStr);
    //     // TembBlobL.CreateInStream(InStr);
    //     // FileName := 'C:\ss.xml';
    //     // File.DownloadFromStream(InStr, 'Export', '', '', FileName);
    // end;

    // procedure CreateXml4()
    // var
    //     EnvNameSpaceLbl: Label 'http://schemas.xmlsoap.org/soap/envelope/';
    //     BarcodeNameSpaceLbl: Label 'http://tempuri.org/';
    // begin
    //     XmlDocumentG := XmlDocument.Create();
    //     XmlDomMgmtG.AddDeclaration(XmlDocumentG, '1.0', 'UTF-8', 'no');
    //     XmlDomMgmtG.AddRootElement(XmlDocumentG, 'Envelope', EnvNameSpaceLbl, EnvelopeXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Body', '', EnvNameSpaceLbl, EnvelopeXmlNodeG);

    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'BarcodeProcessAbsoluteQuantity', '', BarcodeNameSpaceLbl, EnvelopeXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Key', '123', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Barcode', '263301701-OS', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'absoluteQuantity', '10', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'ErrMsg', '', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'IsAdjustment', 'false', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'currentStock', '1', BarcodeNameSpaceLbl, TempXmlNodeG);

    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'BarcodeProcessAbsoluteQuantity', '', BarcodeNameSpaceLbl, EnvelopeXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Key', '123', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'Barcode', '263301701-OS', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'absoluteQuantity', '10', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'ErrMsg', '', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'IsAdjustment', 'false', BarcodeNameSpaceLbl, TempXmlNodeG);
    //     XmlDomMgmtG.AddElement(EnvelopeXmlNodeG, 'currentStock', '1', BarcodeNameSpaceLbl, TempXmlNodeG);

    //     XmlDocumentG.WriteTo(XmlTextG);
    //     Message(XmlTextG);
    // end;

    var
        WebServiceSetupG: Record "Web Service Setup";
        WebServiceTemplateG: Record "Web Service Template";
        TransactionLogG: Record "Web Service Transaction Log";
        ErrorLogG: Record "Web Service Error Log";
        XmlDomMgmtG: Codeunit "XML DOM Mgt.";
        EnvelopeXmlNodeG: XmlNode;
        XmlDocumentG: XmlDocument;
        TempXmlNodeG: XmlNode;
        XmlTextG: Text;
        DirectionG: Option "Incoming Request","Incoming Response","Outgoing Request","Outgoing Response";
        StatusG: Option "To be Processed",Failed,Processed,"Closed Manually","Skip Processing";
        ContentG: HttpContent;
        HeaderG: HttpHeaders;
        ClientG: HttpClient;
        RequestG: HttpRequestMessage;
        ResponseG: HttpResponseMessage;
        ResponseTextG: Text;

        FailedCallErr: Label '<?xml version="1.0"?><WebSerivceError><Error>Web Service call failed.</Error></WebSerivceError>';
        InvalidResErr: Label '<?xml version="1.0"?><WebSerivceError><Error>Invalid response.</Error></WebSerivceError>';

}

