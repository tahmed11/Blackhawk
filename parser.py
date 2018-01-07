import xml.etree.cElementTree as ET
import sys
import os
 
#----------------------------------------------------------------------
def parseXML(xml_file,target):
    """
    Parse XML with ElementTree
    """
    tree = ET.ElementTree(file=xml_file)
    #print tree.getroot()
    root = tree.getroot()
    print "tag=%s, attrib=%s" % (root.tag, root.attrib)
    harvesterfile = os.getcwd()+"/output/"+target+"/harvesterfile.txt"
    emailfile = os.getcwd()+"/output/"+target+"/email.txt"
    #targetfile = os.getcwd()+ "/output/target.txt"
    f = open(harvesterfile, 'w')
    p = open(emailfile, 'w')
    #g = open(targetfile, 'w')
    #g.truncate()
    f.truncate()
    p.truncate()
#add hostnames to harvester file
    for child in root:
        #print child.tag, child.attrib
        if child.tag == "host":
	    hostname = ""
	    ip = ""
            for step_child in child:
		if step_child.tag == "hostname":
			hostname = (step_child.text).lower()
		elif step_child.tag == "ip":
			ip = step_child.text
	            
	    f.write("%s\n" % (hostname))
	    #g.write("%s,%s\n" % (hostname, ip))
	    f.flush()
	    #g.flush()
	    #print "%s" % (ip)
	
	elif child.tag == "email":	                
	    p.write("%s\n" % (child.text))
	    p.flush()
	    #print "%s" % (child.text)
    p.close()
    f.close()
#----------------------------------------------------------------------
if __name__ == "__main__":
    parseXML(sys.argv[1],sys.argv[2])
