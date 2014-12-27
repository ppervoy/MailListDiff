MailListDiff
============
You sent a Holiday postcards, but don't remember whom and case-by-case search takes too much time? A simple, but powerfull, CLI utility gives you a list of unused e-mail address in one list from another.

##Prerequisites
To use this tool you should have following ruby gems installed:
- vpim
- mbox

to install, please use
> sudo gem install &lt;gem_name&rt;

##Input files preparation

#####Apple Mail
Choose Mailbox you'd like to export, click Mailbox -> Export Mailbox... menu and save to convinient location.

For individual .eml files, just drag them to desired location.

#####Apple Contacts
Choose Group you'd like to export, right click and choose Export Group vCard... menu and save to convinient location.

##Usage
```
ruby maillistdiff.rb &lt;src1&rt; &lt;src2&rt; [&lt;output&rt;]

```
where &lt;srcX&rt; might be either .vcf (Apple Contacts export) file or .mbox (Apple Mail Mailbox export) file. If "." is given, the script will search current folder for .eml files (Apple Mail single message export) to extract TO: fields.