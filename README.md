mockA
=====

Unfortunately, mockA, the once open source ABAP mocking framework needed to be deleted from Github.
The reason for this is the following conversation to be found at SCN and which can be considered an official statement of SAP regarding the licensing issue
http://scn.sap.com/community/abap/blog/2013/08/16/share-and-share-alike

Jürgen Schmerder wrote: 

„…This is exactly what we want to encourage in the future - we do suggest Github, we have our own presence on Github (https://github.com/sap) and we're very happy that SAPlink can be used with Github. But if anybody wants to put their ABAP code on Google Code, Subversion or wombling.com, that's fine too. For now, we are getting out of the code hosting business (and with SAP, you never know when we will get back into it, but it's kinda clear that we will. But let's not talk about "strategy". Let's talk about license. Yes. I know. It's boring. And it's annoying. But it's also necessary).
The problem with your approach right now is that legally, you are not allowed to do what you are doing. ABAP is a proprietary language owned and controlled by SAP. We dictate what you are allowed to do and we don't allow you to share ABAP code (no Chris, we won't send the lawyers after you - but we have to make sure we cannot send the lawyers after anyone for sharing their own code). We bloody #*&^$@s....“

In response Chris Paine answered:

“But as per Uwe's comment above, I can't see anything in the customer SAP AS licence agreement that limits the sharing of customer developer code. Whilst there is clearly limitations on the use of the free developer stack to develop code that is shared, I hoped that customer and partner systems (for which we pay a reasonably large licence already) were free of these limitations….”

Uwe Fetzer seems to see it the exact same way:

“…Visual Basic/C++/whatever is a proprietary language owned and controlled by Microsoft. And? Maybe SAPs lawers should read M$ license agreements (chapter 4 "DISTRIBUTABLE CODE") to learn how to do it right (at least better).
And again: I still haven't seen any paragraph where SAP bans me from sharing my own code as SAP customer. "Pic or it didn't happen".…”



These answers were left unanswered.

To make a long story short: In my opinion, without even considering the question if you are developing open source software on a properly licensed SAP system or not, SAP doesn’t give a clear statement if open source software based on ABAP may be shared at platforms like Github or not.
Of course I understand the restriction that an ABAP Trial Netweaver may not be used for open source developments which are to be shared. However, I assume that <1% of all SAP systems worldwide are ABAP Trial Netweavers. What about the rest?
mockA might come back once these questions are clarified or SAP provides a developer license with the right to develop and share open source software for everyone. Unless this happens mockA will remain in hibernation mode.

