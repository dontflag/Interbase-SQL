BEGIN
FOR SELECT B_SUBSTR(PROPS,B_STRPOS(:CurName,PROPS), /*�������� ���� "Field=Value,",���� CurName/PrevName �� ��������� � ������ PROPS */
STRPOS(',',B_SUBSTR(PROPS,B_STRPOS(:CurName,PROPS),200))),B_SUBSTR(PROPS,B_STRPOS(:PrevName,PROPS),
STRPOS(',',B_SUBSTR(PROPS,B_STRPOS(:PrevName,PROPS),200))),SIGNALID FROM SIGNAL WHERE TYPENAME = :TypeName
INTO :PROP,:PREVPROP,:sigID
DO BEGIN
PROP = TRIM(PROP);
PREVPROP = TRIM(PREVPROP);
SELECT PROPS FROM SIGNAL WHERE SIGNALID = :sigID
INTO :CurProps;
if (PROP = '') then begin /*�������� NAME=VALUE, ���� CurName ��������� � ������*/
    SELECT B_SUBSTR(PROPS,B_STRPOS(:CurName,PROPS),100)FROM SIGNAL WHERE SIGNALID= :SIGid
    INTO :PROP;
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRPOS(:PROP,:curprops)-1, /*�������� ���������� ������ �� PROPS*/
    200,'') WHERE SIGNALID = :sigid;
    PROP = SUBSTR(PROP,1,STRLEN(TRIM(PROP)))|| ','; /*�������� :PROP (��. ������ ������)*/
end else /*�������� ���������� ������ �� PROPS ���� CurName � ������ �� ���������*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRPOS(:PROP,:CurProps),
    STRPOS(',',B_SUBSTR(PROPS,STRPOS(:PROP,:curprops)+1,200))+1,'') WHERE SIGNALID = :sigid;
if ((prevname is NULL) or (prevname = ''))   then /*���� CurName ��������������� ������*/
    PREVPROP = '';
else if (PREVPROP ='') then begin /*���� CurName ��������������� ���������*/
    SELECT B_SUBSTR(PROPS,B_STRPOS(','||:PrevName,PROPS)+1,100) FROM SIGNAL WHERE SIGNALID= :SIGid
    INTO :PREVPROP;
    PREVPROP = SUBSTR(PREVPROP,1,STRLEN(TRIM(PREVPROP)))|| ','; /*�������� ����������� :PREVPROP (��. ������ ������)*/
end
SELECT PROPS FROM SIGNAL WHERE SIGNALID = :sigID
INTO :CurProps;
if (PREVPROP ='') then /*���� ���� ��������������� ������*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,0,0,:PROP) WHERE SIGNALID = :sigid; /*�� PROPS ��� STRSTUFF ��������*/
else if (STRPOS(PREVPROP,CurProps)=0) then begin /*��������� � ����� ������*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRLEN(TRIM(PROPS))+1,0,',' || STRSTUFF(:PROP,STRLEN(TRIM(:PROP)),1,''))
    WHERE SIGNALID = :SIGID;
end else  /*��������� ����� PrevName*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRPOS(:PREVPROP,:CurProps)+STRLEN(TRIM(:PREVPROP)),0,:PROP)
    WHERE SIGNALID = :SIGID;
SELECT PROPS FROM SIGNAL WHERE SIGNALID = :sigID
INTO :CurProps; /*��� ������������ ��������� � ���������*/
END
END

