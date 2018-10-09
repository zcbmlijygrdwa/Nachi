function emailNotification(data)
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail','zcbmlijygrdwasb@gmail.com');

% setpref('Internet','SMTP_Username','xxxxx@xxxx.com');
% setpref('Internet','SMTP_Password','xxxxxxxxxx');

setpref('Internet','SMTP_Username',email);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


time = clock;
content = ['Dear Zhenyu, on ' num2str(time(1)) '-' num2str(time(2)) '-' num2str(time(3)) ' ' num2str(time(4)) ':' num2str(time(5)) ':' num2str(time(6)) ',  fx: ' data '.'];

sendmail('zhenyuyang@umail.ucsb.edu','notification for zhenyu',content) ;

end