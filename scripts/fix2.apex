OmniUiCard c = [SELECT Id, IsActive FROM OmniUiCard WHERE Name='visaoHeader360' LIMIT 1];
c.IsActive=false; update c;
c.UniqueName='visaoHeader360_Developer_1';
c.OmniUiCardType='Parent';
update c;
c.IsActive=true; update c;
System.debug('FIX2=' + c.UniqueName);