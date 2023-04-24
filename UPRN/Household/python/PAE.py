#!/usr/bin/env python3
import pymssql
import pandas as pd
import configparser

#x = {}; adr = {}; patient = {}; matcherb = {}; matchb = {};
#matchbig = {};

def DH(date):
    if (date == "None"): return 0

    z = date.split("-")
    year = z[0]
    day = z[2]
    month = z[1]

    y = int(year);
    d = int(day);
    m = int(month);

    # integer divide
    r = round((y-1)//4)-(round((y-1)//100))+(round((y-1)//400))-446
    #print(r)

    ret = 366*r+((y-1841-r)*365)+d

    leap = 29
    if (y%4>0): leap = 28
    elif (y%100>0): leap = 29
    elif (y%400>0): leap = 28

    var = [31,leap,31,30,31,30,31,31,30,31,30,31]
    for i in range(len(var)):
        m = m-1
        if (m == 0): break
        ret = ret + var[i]

    return ret

def read_ini_extra(file_path, dict_obj=None):
    global ZDB, ZUSER, ZPASS, ZHOST, ZPORT
    
    config = configparser.ConfigParser()
    if dict_obj:
        config.read_dict(dict_obj)
    else:
        config.read(file_path)

    print(config)
    
    debug = config["APP"].getboolean("DEBUG")
    print(type(debug))
    
    name = config.get('APP', 'NAME', fallback='NAME is not defined')

    ZDB = config["DATABASE"].get("DB")
    ZUSER = config["DATABASE"].get("USERNAME")
    ZPASS = config["DATABASE"].get("PASSWORD")
    ZHOST =  config["DATABASE"].get("HOST")
    ZPORT = config.get('DATABASE', 'PORT', fallback='PORT is not defined')
    
    print(ZDB)
    return debug

def GMSV3(nor, event_date):
  # check if dead!
  b = 2
  #print(str(patient[nor][0]));
  
  zevent_date = DH(event_date)
  
  dod = patient[nor][0]
  #print(str(dod))
  if (not str(dod) == "None"):
      dod_h = DH(str(dod))
      if (zevent_date >= dod_h):
        #input("patient is dead")
        return b
  
  for i in x[nor]:
    z = i.split("~")
    id = z[0]
    date_start = z[1]
    date_end = z[2]
    type = z[3]

    #print(id + " " + date_start + " [" + date_end + "]")

    #d1 = pd.to_datetime(date_start, errors = 'coerce')
    #d2 = pd.to_datetime(date_end, errors = 'coerce')
    d1 = DH(date_start)
    d2 = DH(date_end)
    
    #print(str(d1) + " " + str(d2))
    
    if (type != "1335267"): continue
    if (not d1==0 and d1>zevent_date): continue
    
    if (d1 <= zevent_date and d2==0): b=1; break
    
    if (d2 >= zevent_date and d2 >= d1): b=1; break

    if (d1 < zevent_date and d2<d1): b=3; break;
  
  return b

def GMSV2(nor, event_date):
  # check if dead!
  b = 2
  #print(str(patient[nor][0]));
  
  dod = patient[nor][0]
  d1 = pd.to_datetime(dod, errors = 'coerce')
  if (not pd.isnull(d1)):
      #input("patient is dead")
      return b

  zevent_date = pd.to_datetime(event_date)
  
  for i in x[nor]:
    z = i.split("~")
    id = z[0]
    date_start = z[1]
    date_end = z[2]
    type = z[3]

    #print(id + " " + date_start + " [" + date_end + "]")

    d1 = pd.to_datetime(date_start, errors = 'coerce')
    d2 = pd.to_datetime(date_end, errors = 'coerce')
    
    if (type != '1335267'): continue
    if (not pd.isnull(d1) and d1>zevent_date): continue
    
    if (d1 <= zevent_date and pd.isnull(d2)): b=1; break
    
    if (d2 >= zevent_date and d2 >= d1): b=1; break

    if (d1 < zevent_date and d2<d1): b=3; break;
  
  return b

########################################## the code starts here - everything above are functions

x = {}; adr = {}; patient = {}; matcherb = {}; matchb = {};
matchbig = {};

#ret = read_ini_extra("D:\\TEMP\\bob.ini")
ret = read_ini_extra("/tmp/bob.ini")

print(ZDB + " " + ZUSER + " " + ZPASS + " " + ZHOST + " " + ZPORT)

conn = pymssql.connect(server=ZHOST, user=ZUSER, password=ZPASS, database=ZDB)

input("Loading patients!  Press Enter to continue...")

patient.clear()

cursor = conn.cursor()

#cursor.execute('SELECT id, date_of_death FROM [compass_gp].[dbo].[patient];')
cursor.execute('select id, date_of_death from [compass_gp].[dbo].[patient] ORDER BY id OFFSET 0 ROWS FETCH NEXT 999999 ROWS ONLY;')
row = cursor.fetchone()
c = 1
while row:
  if (c % 10000 == 0): print(c);
  id = row[0]
  date_of_death = row[1]
  patient[id] = [date_of_death]
  c=c+1
  row = cursor.fetchone()

print(c)

input("Loading episodes of care ....")

cursor = conn.cursor()
cursor.execute('SELECT id, patient_id, registration_type_concept_id, date_registered, date_registered_end FROM [compass_gp].[dbo].[episode_of_care];')
row = cursor.fetchone()
c = 1
x = {}
while row:
  if (c % 10000 == 0): print(c)
  
  id = row[0];
  patient_id = row[1];
  type = row[2];
  date_start = row[3];
  date_end = row[4];

  if (patient_id in patient): x.setdefault(patient_id, []).append(str(id)+"~"+str(date_start)+"~"+str(date_end)+"~"+str(type))
  #print(x);
  #input("press a key:")
    
  c = c + 1;
  row = cursor.fetchone()

ret = GMSV2(20827,"2021-01-01")
print("gmsv2: "+str(ret))
ret = GMSV3(20827,"2021-01-01")
print("gmsv3: "+str(ret))
input("test gms")

### patient_address
input("Start loading addresses...")

adr.clear()

cursor = conn.cursor()

cursor.execute('SELECT id, patient_id, start_date, end_date, use_concept_id, lsoa_2011_code, msoa_2011_code FROM [compass_gp].[dbo].[patient_address];')
row = cursor.fetchone()
c = 1
adridx = {}
while row:
  if (c % 10000 == 0): print(c);
  id = row[0];
  patient_id = row[1];
  start_date = row[2]
  end_date = row[3]
  use = row[4];
  lsoa = row[5];
  msoa = row[6];
  
  #adr.setdefault(patient_id, []).append(str(id)+"~"+str(start_date)+"~"+str(end_date)+"~"+str(use)+"~"+str(lsoa)+"~"+str(msoa))
  if (patient_id in patient):
    adr.setdefault(patient_id,[]).append([id,str(start_date),str(end_date),str(use),str(lsoa),str(msoa)])
    adridx[id] = []
  
  row = cursor.fetchone()
  c = c+1
input("End loading addresses...")

input("loading uprn data using batch sql")

matcherb.clear();
matchb.clear();

c = 1; q = ""

VPROP = {"R":"","RD":"","RD01":"","RD02":"","RD03":"","RD04":"","RD06":"","RD07":"","RD10":"","RH02":"","U":"","UC":"","UP":"","X":""}
#zevent_date = pd.to_datetime("2021-01-01")
zevent_date = DH("2021-01-01")

sql = "select id, patient_address_id, uprn, qualifier, uprn_property_classification from [compass_gp].[dbo].[patient_address_match]" # order by id desc"

print(sql)
input("press a key to run the sql:")

cursor = conn.cursor()
cursor.execute(sql)
row = cursor.fetchone()
c = 1

matchbig.clear();

while row:
    if (c % 10000 == 0):
        print(c);
    c = c + 1
    match_id = row[0]
    adr_id = row[1];

    if (adr_id not in adridx): row = cursor.fetchone(); continue;

    uprn = row[2];
    qualifier = row[3];
    classification = row[4];

    #start_date = addr[str(adr_id)][1]
        
    #end_date = addr[str(adr_id)][2]
    #use = addr[str(adr_id)][3]
    #lsoa = addr[str(adr_id)][4]
    #msoa = addr[str(adr_id)][5]

    if (adr_id in matchbig):
        m_id = matchbig[adr_id][0]
        #print("testing"+str(match_id)+">"+str(m_id))
        if (match_id > m_id):
            #print("yup"+str(adr_id))
            matchbig[adr_id] = [match_id, uprn, qualifier, classification]
        
    if (adr_id not in matchbig):
        matchbig[adr_id] = [match_id, uprn, qualifier, classification]
    
    #matchbig.setdefault(adr_id, []).append(str(uprn)+"~"+str(match_id)+"~"+str(qualifier)+"~"+str(classification))
    
    row = cursor.fetchone()
    #print(adr_id)

input("match end:")

matcherb.clear()

#outputFile = open("d:/temp/hh_output.txt","w")
outputFile = open("/tmp/hh_output.txt","w")

#print(adr[346604])
#print(matchbig[346605])
#print(matchbig[1956015417])
#input("** press a key:")

c = 1
for nor in patient:
  #print(nor)
  #if (nor == 306829): print("test"); input("?")

  if (c % 10000 == 0): print(c)
  c = c +1
  
  #ret = GMSV2(nor, "2021-01-01")
  ret = GMSV3(nor, "2021-01-01")
  if (ret == 2):
      outputFile.write(str(nor) + "\t2\n")
      continue
    
  if (nor in adr):
      blist = sorted(adr[nor], key=lambda x:x[0], reverse=True)
      if (nor == 490120):
        print(blist)
        input("test:")
      #for i in adr[nor]:
      for i in range(len(blist)):
        #z = i.split("~")
        #id = int(z[0]); start_date = z[1]; end_date = z[2];
        #use = z[3]; lsoa = z[4]; msoa = z[5];
          
        id = int(blist[i][0])
        start_date = blist[i][1]; end_date = blist[i][2];
        use = blist[i][3]; lsoa = blist[i][4]; msoa = blist[i][5];

        #print(str(nor) + " " + str(id) + " " + str(start_date) + " " + str(end_date) + " " + use)
        if (nor == 490120 and id in matchbig):
          print(matchbig[id])
          input("test2:")

        if (use == "1335360"): continue

        uprn = ""
        if (id in matchbig):
            uprn = matchbig[id][1]; qualifier = matchbig[id][2];
            classification = matchbig[id][3];
            #print(str(classification) + " " + str(uprn))


        if (uprn == ""): continue
        
        if (classification not in VPROP.keys()): continue
        if (qualifier != "Best (residential) match"): continue
        
        #d1 = pd.to_datetime(start_date, errors = 'coerce')
        #d2 = pd.to_datetime(end_date, errors = 'coerce')
        d1 = DH(start_date)
        d2 = DH(end_date)

        #if (d1 <= zevent_date or pd.isnull(d1)) and (d2 >= zevent_date or pd.isnull(d2)):
        if (d1 <= zevent_date or d1==0) and (d2 >= zevent_date or d2==0):
            #print(str(nor) + " " + str(uprn));
            #matcherb[nor] = [id, adr_id, uprn, start_date, end_date, use, classification, lsoa, msoa]
            outputFile.write(str(nor) + "\t" + str(adr_id) + "\t" + str(uprn) + "\t" + str(start_date) + "\t" + end_date + "\t" + use + "\t" + classification + "\t" + lsoa + "\t" + msoa + "\n")
            break

        
outputFile.close()

    #print(id)
    #addr[id] = [nor, start_date, end_date, use, lsoa, msoa]
        
    #zsort = sorted(matchbig[id], key=lambda x:x[1], reverse=True)
    #print(matchbig[id])
    #print(zsort)


##for id in patient:
##  if (c % 7000 == 0):
##      q = q[0:len(q)-1]
##      sql = "select adr.patient_id, match.id, match.patient_address_id, match.match_date, match.uprn, adr.start_date, adr.end_date, use_concept_id, lsoa_2011_code, msoa_2011_code,"
##      sql = sql + "uprn_property_classification, qualifier "
##      sql = sql + "from [compass_gp].[dbo].[patient_address] adr "
##      sql = sql + "join [compass_gp].[dbo].[patient_address_match] match on match.patient_address_id = adr.id "
##      sql = sql + "where adr.patient_id in ("+q+")"
##      #sql = sql + "order by patient_id, match.id desc"
##      sql = sql + "order by match.id desc"
##
##      print(c)
##      #print(sql);
##      #input("press a key...")
##      
##      cursor = conn.cursor()
##      cursor.execute(sql)
##      row = cursor.fetchone()
##      q = ""
##      while row:
##        nor = row[0]; id = row[1]; adr_id = row[2]; match_date = row[3]; uprn = row[4];
##        start_date = str(row[5]); end_date = str(row[6]); use = row[7]; lsoa = row[8]; msoa = row[9];
##        classi = row[10]; qualifier = row[11];
##
##        row = cursor.fetchone()
##        
##        if (use == 1335360): continue
##        if (classi not in VPROP.keys()): continue
##        if (qualifier != "Best (residential) match"): continue
##      
##        #if (adr_id not in matchb):
##        if (nor not in matcherb):
##            
##            d1 = pd.to_datetime(start_date, errors = 'coerce')
##            d2 = pd.to_datetime(end_date, errors = 'coerce')
##
##            #print(str(d1) + " " + str(d2))
##      
##            if (d1 <= zevent_date or pd.isnull(d1)) and (d2 >= zevent_date or pd.isnull(d2)):
##                #print("matcher"+str(nor))
##                matcherb[nor] = [id, adr_id, uprn, match_date, start_date, end_date, use, classi, lsoa, msoa]
##                #matchb[adr_id] = []
##
##      #print(matcherb)
##      #input("press a key ...")
##           
##  q = q + str(id) + ","
##  c =c +1

#ret = PLACEATEVT(id, "2021-01-01", 0, 0, conn)
  
input("pae end")

conn.close()
