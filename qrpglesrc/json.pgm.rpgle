**free
ctl-opt dftactgrp(*no) actgrp(*new);
ctl-opt bnddir('YAJL') decedit('0.');

/include qrpgleref/yajl_h

dcl-ds resultDS qualified;
  succes ind;
  error varchar(500);
end-ds;

dcl-ds piep qualified;
  burp varchar(2);
  res  like(resultDS);
end-ds;

dcl-s errMsg varchar(500);
dcl-s retCode int(10);
dcl-ds res likeds(resultDS);
// ---------------
// MAIN
*inlr = *on;

retCode = yajl_genOpen(*on);
retCode = yajl_beginObj();
retCode = yajl_addChar('burp':'hehe');
res.succes = *on;
res.error = 'Hier staat een foutje';
fill_result(res);
retCode = yajl_endObj();

retCode = yajl_saveBuf('/home/HEKKR400/test.json':errMsg);

yajl_genClose();


return;

dcl-proc fill_result;
  DCL-PI *N int(10);
    result likeds(resultDS);
  END-PI;
  dcl-s retc int(10);
  retc = yajl_beginObj('result');
  retc = yajl_addBool('success':result.succes);
  retc = yajl_addChar('errmsg':result.error);
  retc = yajl_endObj();

  return 0;
end-proc;