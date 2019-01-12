MailListDiff
============
You sent a Holiday postcards, but don't remember whom. No time to check case-by-case? A simple ruby CLI utility gives you a list of unused e-mail address in one list versus another.

##Prerequisites
To use this tool you should have following ruby gems installed:
- mail
- vpim
- mbox

to install, please use

```
sudo gem install "gem_name"
```
Works with Ruby version 2.1.4

##Input files preparation

#####Apple Mail
Choose Mailbox you'd like to export (it's easy to use Smart Mailbox), click Mailbox -> Export Mailbox... menu and save to convinient location.

For individual .eml files, just drag them to desired location.

#####Apple Contacts
Choose (Smart) Group you'd like to export, right click and choose Export Group vCard... menu and save to convinient location.

##Usage
```
ruby maillistdiff.rb "src1" "src2" ["output"]
```
where "srcX" might be either .vcf (Apple Contacts export) file or .txt (output of this script) or .mbox (Apple Mail Mailbox export) file. If "." is given, the script will search current folder for .eml files (Apple Mail single message export) to extract *TO:* fields (if .mbox is used, script will prompt for *TO:* or *FROM:* field. If blank, will search *BCC:*).

Just copy result from terminal or output file into new message's BCC (recommended for mass mail) and you're sure that all people from your updated mailing list "src2" who haven't been mailed in "src1" will receive your communication.

##EXAMPLE

You composed a list of greeting cards in your Drafts. Some of them are addressed to a person, others to a group in BCC: field. Previously you sent some messages as well. You don't want to send greetings twice, but can't miss any of your contacts.

- First you create smart mailbox in your Appli Mail with a rule set: Sybject "Happy New Year" and sent within last week. Once it's done, you can check what's inside and refine search rule if needed. Export this smart mailbox to GreetingsSent.mbox file
- Export your Drafts to Drafts.mbox
- Export you Contacts group to ToBeGreeted.vcf
- run following to create two lists of addresses. Please note, I use "." here to exclude addresses in .eml files in my working directory. E.g. if there are none, I will get a list of addresses from source.
```
ruby maillistdiff.rb GreetingsSent.mbox . GreetingsSent.txt
ruby maillistdiff.rb Drafts.mbox . Drafts.txt
```
- you should get two txt files with all prepared or already sent. Just use your favorite text edit to combine these two lists and save to Composed.txt
- run following command to get TODO.txt file with a list of addresses you need.
```
ruby maillistdiff.rb ToBeGreeted.vcf Composed.txt TODO.txt
```
- Just copy addresses from TODO.txt to a previously prepared e-mail massage and hit send! Enjoy!

##### Hint
You can change value of variable DEBUG from *false* to *true* to get extra info on what's going on.
