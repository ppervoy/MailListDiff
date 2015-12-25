MailListDiff
============
You sent a Holiday postcards, but don't remember whom and case-by-case search takes too much time? A simple, but powerfull, CLI utility gives you a list of unused e-mail address in one list from another.

##Prerequisites
To use this tool you should have following ruby gems installed:
- vpim
- mbox

to install, please use

```
sudo gem install "gem_name"
```
Works with Ruby version 2.1.4
Use rbenv to set local version.

##Input files preparation

#####Apple Mail
Choose Mailbox you'd like to export, click Mailbox -> Export Mailbox... menu and save to convinient location.

For individual .eml files, just drag them to desired location.

#####Apple Contacts
Choose Group you'd like to export, right click and choose Export Group vCard... menu and save to convinient location.

##Usage
```
ruby maillistdiff.rb "src1" "src2" ["output"]
```
where "srcX" might be either .vcf (Apple Contacts export) file or .txt (output of this script) or .mbox (Apple Mail Mailbox export) file. If "." is given, the script will search current folder for .eml files (Apple Mail single message export) to extract *TO:* fields (if .mbox is used, script will prompt for *TO:* or *FROM:* field).

Just copy result from terminal or output file into new message's BCC (recommended for mass mail) and you're sure that all people from your updated mailing list "src2" who haven't been mailed in "src1" will receive your communication.

Hit send! Enjoy!
