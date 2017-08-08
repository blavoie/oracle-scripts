We appreciate your interest in Lab128. Below is minimum information 
needed to get the program installed and running. For more information, 
please check "Getting Started" chapter of Lab128 Help guide.



SYSTEM REQUIREMENTS.

- CPU: 586-compatible or later (Intel, AMD etc.);
- 1024 x 768 monitor or better. Lab128 presents a lot of graphical 
  information, the monitor with high number of pixels is suggested;
- MS Windows NT, 2000, XP, Vista, Windows 7;
- Oracle Client software with Oracle Call Interface (OCI) installed 
  (OCI is installed by default for all latest Oracle clients).
  See also FAQ question "I have a computer with no Oracle software / 
  Oracle client installed. What options do I have to get Lab128 running?"
  (http://www.lab128.com/lab128_faq.html#g3_q50);
- Oracle Database Server, versions supported: 8i, 9i, 10g, 11g.



INSTALLATION.

To install, just extract files from lab128.zip into some directory and 
run lab128.exe. That's all! No administrator privilege is required to 
install and run Lab128. 

lab128.exe is a digitally signed file; MS Windows automatically checks 
the integrity of the file when it is invoked. The program does not use 
the Windows registry, as all settings are stored in text files in the 
directory where Lab128 was started. It is advisable to create a dedicated 
directory, for example C:\Program Files\Lab128, and keep files there. 
This directory should be writeable to allow for the saving of user 
preferences. To uninstall Lab128, simply delete the Lab128 directory. 
 


UPGRADE FROM VERSION 1.5.x

Files supplied in this package should overwrite files of the same name from 
the previous version. All setting files from the 1.5.x version are 
compatible with the new version. As an alternative, you can install 
this new version into a new directory and, if you wish, copy all setting 
files into this directory. This way you can run both versions. 



UPGRADE FROM PRE-1.5.9.8 LAB128 ON WINDOWS 7

If you have been running a pre-1.5.9.8 version of Lab128 on Windows 7, 
and it was installed in the C:\Program Files\Lab128 directory, please
read the section "Upgrade from pre-1.5.9.8 Lab128 on Windows 7" in the 
"Installation and Setup" chapter of the documentation (lab128.chm or online 
http://www.lab128.com/lab128_rg/html/install.html#win7_upgrade).


AUTHORIZATION KEYCODE.

You will need an authorization Keycode to activate Lab128. If you already 
have the Keycode, then proceed to the next chapter. You can obtain the 
the trial keycode at: 
http://www.lab128.com/lab128_download.html
If you have a purchased license, the Keycode should be e-mailed to you. 
If you purchased Lab128 and have not received the Keycode, please contact 
us at support@lab128.com.


REQUIRED MINIMUM OF PRIVILEGES.

You can use an existing account to connect to Oracle or you can create a new 
account dedicated to Lab128. In both cases, the account should be granted 
SELECT ANY DICTIONARY role (Oracle 9+), or an equivalent set of grants in 
earlier Oracle versions. The account should be able to query v$, dba_, and 
sys.xxx$ tables (such as sys.fet$ etc.). A dedicated account is recommended 
for security reasons to make it is easier to grant a bare minimum of required 
privileges. 

See also lab128.chm Reference guide, Getting Started | Installation and Setup, 
for more details or use this link to online documentation:
http://www.lab128.com/lab128_rg/html/install.html




Lab128 Team
support@lab128.com

