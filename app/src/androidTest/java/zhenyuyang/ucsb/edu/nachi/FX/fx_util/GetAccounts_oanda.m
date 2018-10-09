function account = GetAccounts_oanda()
account = GetAccounts;
account.balance = str2num(account.balance);
account.marginAvailable = str2num(account.marginAvailable);
account.NAV = str2num(account.NAV);
account.marginUsed = account.NAV - account.marginAvailable;
end 