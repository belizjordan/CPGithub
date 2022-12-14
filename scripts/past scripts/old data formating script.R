###### OLD SCRIPT!!! Just keeping for records #######



#NONE OFTHIS WORKS YET
# WHY does it not show numbers?
#all numbers are NA..........

# using the Qualtrics filtered data, 43 responses (as of jUne 22)
# it said there were 56 responses, 10 labled exclusions, the 7 year old, and a faulty one with no data were deleted
# however we should have 45 legit kids to analyze but filter gave us only 43?
    # must figure that out
    # anyway doing this now to at least do analyses without my exclusions included


# resuing code from 'w katie data june 15.R'
library(readxl)
library(tidyverse)
library(ggplot2)
library(lme4)
library(lmerTest)
library(car)
library(gitcreds)
library(dplyr)
library(tidyr)


d <- read_excel("~/Desktop/data/43 filtered pain data.xlsx")

d<- d %>% 
  select(-Duration, -IPAddress, -EndDate, -Finished, 
         -RecipientLastName, -RecipientFirstName, -RecipientEmail, 
         -ExternalReference, -LocationLatitude, -LocationLongitude, 
         -DistributionChannel, -UserLanguage, -mturkcode, -StartDate,
         -Status, -Progress, -RecordedDate, -ResponseId, -Q.d1,) #dont think it deletes those end columns that are numbers 1-8 /useless, later renamed them na1/na2 etc can delete after that?


#exclusions for control questions
#exclusions will be 1, non excluded will be 0
d2 <- d %>% 
  mutate(exclude= case_when(Qc1=="yes"~1,
                            Qc2=="yes"~1,	
                            Qc3=="yes"~1,	
                            Qc4=="yes"~1,
                            TRUE~0))
# moved this re-naming up...
# rename some variables / may need to add participant sex in a different place? add race later?
vars = c('condition','cp_number','cp_age','cp_sex','Qpractice1','Qpractice1.5',
         'Qpractice2','Qpractice2.5','Qpractice3','Qpractice3.5','Q1', 'Q1.5', 'Q2', 'Q2.5', 
         'Q3','Q3.5', 'Q4', 'Q4.5', 'Q5', 'Q5.5', 'Q6', 'Q6.5', 'Q7', 'Q7.5', 'Q8', 'Q8.5',
         'Qctrl1', 'Qctrl1.5', 'Qctrl2', 'Qctrl2.5','Qctrl3', 'Qctrl3.5', 'Qctrl4', 'Qctrl4.5',
         'Q9', 'Q9.5', 'Q10', 'Q10.5','Q11','Q11.5', 'Q12', 'Q12.5', 'Q13', 'Q13.5', 'Q14',
         'Q14.5', 'Q15', 'Q15.5', 'Q16', 'Q16.5',
         'Q17', 'Q17.5', 'Q18', 'Q18.5','Q19','Q19.5', 'Q20', 'Q20.5', 'Q21', 'Q21.5', 'Q22',
         'Q22.5', 'Q23', 'Q23.5', 'Q24', 'Q24.5',
         'Q25', 'Q25.5', 'Q26', 'Q26.5','Q27','Q27.5', 'Q28', 'Q28.5', 'Q29', 'Q29.5', 'Q30',
         'Q30.5', 'Q31', 'Q31.5', 'Q32', 'Q32.5',
         'Q33', 'Q33.5', 'Q34', 'Q34.5','Q35','Q35.5', 'Q36', 'Q36.5', 'Q37', 'Q37.5', 'Q38',
         'Q38.5', 'Q39', 'Q39.5', 'Q40', 'Q40.5',
         'Q41', 'Q41.5', 'Q42', 'Q42.5','Q43','Q43.5', 'Q44', 'Q44.5', 'Q45', 'Q45.5', 'Q46',
         'Q46.5', 'Q47', 'Q47.5', 'Q48', 'Q48.5',
         'Q49', 'Q49.5', 'Q50', 'Q50.5','Q51','Q51.5', 'Q52', 'Q52.5', 'Q53', 'Q53.5', 'Q54',
         'Q54.5', 'Q55', 'Q55.5', 'Q56', 'Q56.5',
         'Q57', 'Q57.5', 'Q58', 'Q58.5','Q59','Q59.5', 'Q60', 'Q60.5', 'Q61', 'Q61.5', 'Q62',
         'Q62.5', 'Q63', 'Q63.5', 'Q64', 'Q64.5', 
         'should_this_be_excluded','should_text1','should_text2','cp_pains_experienced', 'na1','na2','na3','na4', 'na5', 'na6','na7', 'na8', 'exclude')
colnames(d2) = vars 


# have not yet done broken arm 0 rating exclusions. that can wait.

#count amount of valid kids, after control q exclusions/rename
subs<-d2 %>%
  select(cp_number, cp_age)%>%
  group_by(cp_age) %>%
  distinct

count_subs<-subs%>%
  group_by(cp_age) %>%
  summarize(n())

#subset by condition (for all 8 conditions) include particpant number and age too
# note: need to remove 4.1.1, she is 3 not 4 so not in age range (first participant i tested, at lab school)



#make sure column renames align with the actual columns/no additions or reductions shifting it.

d_1<-d2 %>% 
  filter(condition=="1") %>% #selecting only condition 1 participants
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q1,	Q1.5,	Q2,	Q2.5,	Q3,	Q3.5, Q4,	Q4.5,	Q5,	Q5.5,	Q6,	Q6.5,	Q7,	Q7.5,	Q8,	Q8.5)%>%
  mutate(burned.tongue_WAF=case_when(Q1=="yes"~Q1.5,
                                     Q1=="no"~'0'),
         broken.arm_WCF=case_when(Q2=="yes"~Q2.5, # will need to exclude 0s for broken arm
                                  Q2=="no"~'0'),
         stomach.ache_WAM=case_when(Q3=="yes"~Q3.5,
                                    Q3=="no"~'0'),
         paper.cut_WCM=case_when(Q4=="yes"~Q4.5,
                                 Q4=="no"~'0'),
         skinned.knees_BAF=case_when(Q5=="yes"~Q5.5,
                                     Q5=="no"~'0'),
         bruised.leg_BCF=case_when(Q6=="yes"~Q6.5,
                                   Q6=="no"~'0'),
         splinter_BAM=case_when(Q7=="yes"~Q7.5,
                                Q7=="no"~'0'),
         bee.sting_BCM=case_when(Q8=="yes"~Q8.5,
                                 Q8=="no"~'0'))

#condition 1 is done, above   
#each condition  will be new question numbers/new pairing of injury and character demos (WAF etc)

d_2<- d2 %>%
  filter(condition=="2") %>% 
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q9,	Q9.5,	Q10,	Q10.5,	Q11,	Q11.5,	Q12,	Q12.5,	Q13,	Q13.5,
         Q14,	Q14.5,	Q15,	Q15.5,	Q16,	Q16.5)%>%
  mutate(paper.cut_WAF=case_when(Q9=="yes"~Q9.5,
                                 Q9=="no"~'0'),
         splinter_WCF=case_when(Q10=="yes"~Q10.5,
                                Q10=="no"~'0'),
         bruised.leg_WAM=case_when(Q11=="yes"~Q11.5,
                                   Q11=="no"~'0'),
         burned.tongue_WCM=case_when(Q12=="yes"~Q12.5,
                                     Q12=="no"~'0'),
         stomach.ache_BAF=case_when(Q13=="yes"~Q13.5,
                                    Q13=="no"~'0'),
         bee.sting_BCF=case_when(Q14=="yes"~Q14.5,
                                 Q14=="no"~'0'),
         broken.arm_BAM=case_when(Q15=="yes"~Q15.5, # broken arm, will exclude 0s
                                  Q15=="no"~'0'),
         skinned.knees_BCM=case_when(Q16=="yes"~Q16.5,
                                     Q16=="no"~'0'))


d_3<-d2 %>% 
  filter(condition=="3") %>%
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q17, Q17.5, Q18, Q18.5, Q19, Q19.5, Q20, Q20.5, Q21, Q21.5, Q22, Q22.5, Q23, Q23.5, Q24, Q24.5) %>%
  mutate(skinned.knees_WAF=case_when(Q17=="yes"~Q17.5,
                                     Q17=="no"~'0'),
         bruised.leg_WCF=case_when(Q18=="yes"~Q18.5,
                                   Q18=="no"~'0'),
         bee.sting_WAM=case_when(Q19=="yes"~Q19.5,
                                 Q19=="no"~'0'),
         splinter_WCM=case_when(Q20=="yes"~Q20.5,
                                Q20=="no"~'0'),
         paper.cut_BAF=case_when(Q21=="yes"~Q21.5,
                                 Q21=="no"~'0'),
         broken.arm_BCF=case_when(Q22=="yes"~Q22.5, # broken arm, exclude 0
                                  Q22=="no"~'0'),
         burned.tongue_BAM=case_when(Q23=="yes"~Q23.5,
                                     Q23=="no"~'0'),
         stomach.ache_BCM=case_when(Q24=="yes"~Q24.5,
                                    Q24=="no"~'0'))

d_4<-d2 %>% 
  filter(condition=="4") %>%
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q25, Q25.5, Q26, Q26.5, Q27, Q27.5, Q28, Q28.5, Q29, Q29.5, Q30, Q30.5, Q31, Q31.5, Q32, Q32.5) %>%
  mutate(bee.sting_WAF=case_when(Q25=="yes"~Q25.5,
                                 Q25=="no"~'0'),
         stomach.ache_WCF=case_when(Q26=="yes"~Q26.5,
                                    Q26=="no"~'0'),
         broken.arm_WAM=case_when(Q27=="yes"~Q27.5, # broken arm, exclude 0
                                  Q27=="no"~'0'),
         skinned.knees_WCM=case_when(Q28=="yes"~Q28.5,
                                     Q28=="no"~'0'),
         splinter_BAF=case_when(Q29=="yes"~Q29.5,
                                Q29=="no"~'0'),
         burned.tongue_BCF=case_when(Q30=="yes"~Q29.5,
                                     Q30=="no"~'0'),
         bruised.leg_BAM=case_when(Q31=="yes"~Q30.5,
                                   Q31=="no"~'0'),
         paper.cut_BCM=case_when(Q32=="yes"~Q32.5,
                                 Q32=="no"~'0'))


d_5<-d2 %>% 
  filter(condition=="5") %>%
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q33, Q33.5, Q34, Q34.5, Q35, Q35.5, Q36, Q36.5, Q37, Q37.5, Q38, Q38.5, Q39, Q39.5, Q40, Q40.5) %>%
  mutate(stomach.ache_WAF=case_when(Q33=="yes"~Q33.5,
                                    Q33=="no"~'0'),
         burned.tongue_WCF=case_when(Q34=="yes"~Q34.5,
                                     Q34=="no"~'0'),
         splinter_WAM=case_when(Q35=="yes"~Q35.5,
                                Q35=="no"~'0'),
         bee.sting_WCM=case_when(Q36=="yes"~Q36.5,
                                 Q36=="no"~'0'),
         bruised.leg_BAF=case_when(Q37=="yes"~Q37.5,
                                   Q37=="no"~'0'),
         skinned.knees_BCF=case_when(Q38=="yes"~Q38.5,
                                     Q38=="no"~'0'),
         paper.cut_BAM=case_when(Q39=="yes"~Q39.5,
                                 Q39=="no"~'0'),
         broken.arm_BCM=case_when(Q40=="yes"~Q40.5, # broken arm, exclude 0
                                  Q40=="no"~'0'))

d_6<-d2 %>% 
  filter(condition=="6") %>%
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q41, Q41.5, Q42, Q42.5, Q43, Q43.5, Q44, Q44.5, Q45, Q45.5, Q46, Q46.5, Q47, Q47.5, Q48, Q48.5) %>%
  mutate(bruised.leg_WAF=case_when(Q41=="yes"~Q41.5,
                                   Q41=="no"~'0'),
         skinned.knees_WCF=case_when(Q42=="yes"~Q42.5,
                                     Q42=="no"~'0'),
         burned.tongue_WAM=case_when(Q43=="yes"~Q43.5,
                                     Q43=="no"~'0'),
         stomach.ache_WCM=case_when(Q44=="yes"~Q44.5,
                                    Q44=="no"~'0'),
         broken.arm_BAF=case_when(Q45=="yes"~Q45.5, # broken arm, exclude 0
                                  Q45=="no"~'0'),
         paper.cut_BCF=case_when(Q46=="yes"~Q46.5,
                                 Q46=="no"~'0'),
         bee.sting_BAM=case_when(Q47=="yes"~Q47.5,
                                 Q47=="no"~'0'),
         splinter_BCM=case_when(Q48=="yes"~Q48.5,
                                Q48=="no"~'0'))

d_7<-d2 %>% 
  filter(condition=="7") %>%
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q49, Q49.5, Q50, Q50.5, Q51, Q51.5, Q52, Q52.5, Q53, Q53.5, Q54, Q54.5, Q55, Q55.5, Q56, Q56.5) %>%
  mutate(broken.arm_WAF=case_when(Q49=="yes"~Q49.5, # broken arm, exclude 0
                                  Q49=="no"~'0'),
         paper.cut_WCF=case_when(Q50=="yes"~Q50.5,
                                 Q50=="no"~'0'),
         skinned.knees_WAM=case_when(Q51=="yes"~Q51.5,
                                     Q51=="no"~'0'),
         bruised.leg_WCM=case_when(Q52=="yes"~Q52.5,
                                   Q52=="no"~'0'),
         bee.sting_BAF=case_when(Q53=="yes"~Q53.5,
                                 Q53=="no"~'0'),
         splinter_BCF=case_when(Q54=="yes"~Q54.5,
                                Q54=="no"~'0'),
         stomach.ache_BAM=case_when(Q55=="yes"~Q55.5,
                                    Q55=="no"~'0'),
         burned.tongue_BCM=case_when(Q56=="yes"~Q56.5,
                                     Q56=="no"~'0'))

d_8<-d2 %>% 
  filter(condition=="8") %>%
  select(condition, cp_number, cp_age, cp_sex, Qctrl1,	
         Qctrl1.5,	Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
         Q57, Q57.5, Q58, Q58.5, Q59, Q59.5, Q60, Q60.5, Q61, Q61.5, Q62, Q62.5, Q63, Q63.5, Q64, Q64.5) %>%
  mutate(splinter_WAF=case_when(Q57=="yes"~Q57.5, 
                                Q57=="no"~'0'),
         bee.sting_WCF=case_when(Q58=="yes"~Q58.5,
                                 Q58=="no"~'0'),
         paper.cut_WAM=case_when(Q59=="yes"~Q59.5,
                                 Q59=="no"~'0'),
         broken.arm_WCM=case_when(Q60=="yes"~Q60.5, # broken arm, exclude 0
                                  Q60=="no"~'0'),
         burned.tongue_BAF=case_when(Q61=="yes"~Q61.5,
                                     Q61=="no"~'0'),
         stomach.ache_BCF=case_when(Q62=="yes"~Q62.5,
                                    Q62=="no"~'0'),
         skinned.knees_BAM=case_when(Q63=="yes"~Q63.5,
                                     Q63=="no"~'0'),
         bruised.leg_BCM=case_when(Q64=="yes"~Q64.5,
                                   Q64=="no"~'0'))


# now long to wide or wide to long, whatever (wide to long?)
#don't yet have columns for: injury, rating, sex, age, race (and participant sex/age/race)
# will exclude kids with '1' values in 'exclude' column, keep kids the '0's
# also make R markdown /sections soon

#6/22, for the 43 kids verison (filtered)
#start making wide format, using Katie's code, file called "wide2long.R"
# doing condition 1 first 
# take from d2 or take from d_1?

#make column injury in long1
#1
long1 <- d_1 %>% 
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q1, Q1.5,	Q2,	Q2.5,	Q3,	Q3.5, Q4,	Q4.5,	Q5,	Q5.5,	Q6,	Q6.5,	Q7,	Q7.5,	Q8,	Q8.5))
#making demographic categories in long1b
long1b <- long1 %>% mutate(race=case_when(injury %in% c('burned.tongue_WAF', 'broken.arm_WCF', 'stomach.ache_WAM', 'paper.cut_WCM') ~ "white",
                                          injury %in% c('skinned.knees_BAF', 'bruised.leg_BCF', 'splinter_BAM', 'bee.sting_BCM') ~ "black"),
                           sex = case_when(injury %in% c('burned.tongue_WAF', 'broken.arm_WCF','skinned.knees_BAF', 'bruised.leg_BCF') ~ "female",
                                           injury %in% c('stomach.ache_WAM', 'paper.cut_WCM','splinter_BAM', 'bee.sting_BCM') ~ "male"), 
                           age = case_when(injury %in% c('burned.tongue_WAF','stomach.ache_WAM','skinned.knees_BAF','splinter_BAM') ~"adult",
                                           injury %in% c('broken.arm_WCF','paper.cut_WCM','bruised.leg_BCF','bee.sting_BCM')~"child"))

# repeat long1/long1b steps for conditions 2-8

#2
long2 <- d_2 %>%
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q9,	Q9.5,	Q10,	Q10.5,	Q11,	Q11.5,	Q12,	Q12.5,	Q13,	Q13.5, Q14,	Q14.5,	Q15,	Q15.5,	Q16,	Q16.5))

long2b <- long2 %>% mutate(race=case_when(injury %in% c('paper.cut_WAF','splinter_WCF','bruised.leg_WAM','burned.tongue_WCM') ~ "white",
                                          injury %in% c('stomach.ache_BAF', 'bee.sting_BCF', 'broken.arm_BAM', 'skinned.knees_BCM') ~ "black"),
                           sex = case_when(injury %in% c('paper.cut_WAF','splinter_WCF','stomach.ache_BAF','bee.sting_BCF') ~ "female",
                                           injury %in% c('bruised.leg_WAM','burned.tongue_WCM','broken.arm_BAM', 'skinned.knees_BCM') ~ "male"), 
                           age = case_when(injury %in% c('paper.cut_WAF','bruised.leg_WAM','stomach.ache_BAF','broken.arm_BAM') ~"adult",
                                           injury %in% c('splinter_WCF','burned.tongue_WCM','bee.sting_BCF','skinned.knees_BCM')~"child"))

#3
long3 <- d_3 %>% 
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q17, Q17.5, Q18, Q18.5, Q19, Q19.5, Q20, Q20.5, Q21, Q21.5, Q22, Q22.5, Q23, Q23.5, Q24, Q24.5))

long3b <- long3 %>% mutate(race=case_when(injury %in% c('skinned.knees_WAF','bruised.leg_WCF','bee.sting_WAM','splinter_WCM') ~ "white",
                                          injury %in% c('paper.cut_BAF','broken.arm_BCF','burned.tongue_BAM','stomach.ache_BCM') ~ "black"),
                           sex = case_when(injury %in% c('skinned.knees_WAF','bruised.leg_WCF','paper.cut_BAF','broken.arm_BCF') ~ "female",
                                           injury %in% c('bee.sting_WAM','splinter_WCM','burned.tongue_BAM','stomach.ache_BCM') ~ "male"), 
                           age = case_when(injury %in% c('skinned.knees_WAF','bee.sting_WAM','paper.cut_BAF','burned.tongue_BAM') ~"adult",
                                           injury %in% c('bruised.leg_WCF','splinter_WCM','broken.arm_BCF','stomach.ache_BCM')~"child"))
#4
long4 <- d_4 %>% 
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q25, Q25.5, Q26, Q26.5, Q27, Q27.5, Q28, Q28.5, Q29, Q29.5, Q30, Q30.5, Q31, Q31.5, Q32, Q32.5))

long4b <- long4 %>% mutate(race=case_when(injury %in% c('bee.sting_WAF','stomach.ache_WCF','broken.arm_WAM','skinned.knees_WCM') ~ "white",
                                          injury %in% c('splinter_BAF','burned.tongue_BCF','bruised.leg_BAM','paper.cut_BCM') ~ "black"),
                           sex = case_when(injury %in% c('bee.sting_WAF','stomach.ache_WCF','splinter_BAF','burned.tongue_BCF') ~ "female",
                                           injury %in% c('broken.arm_WAM','skinned.knees_WCM','bruised.leg_BAM','paper.cut_BCM') ~ "male"), 
                           age = case_when(injury %in% c('bee.sting_WAF','broken.arm_WAM','splinter_BAF','bruised.leg_BAM') ~"adult",
                                           injury %in% c('stomach.ache_WCF','skinned.knees_WCM','burned.tongue_BCF','paper.cut_BCM')~"child"))
# theres two splinter_BAF's that have a 'NA' and not a 0?

#5
long5 <- d_5 %>% 
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q33, Q33.5, Q34, Q34.5, Q35, Q35.5, Q36, Q36.5, Q37, Q37.5, Q38, Q38.5, Q39, Q39.5, Q40, Q40.5))

long5b <- long5 %>% mutate(race=case_when(injury %in% c('stomach.ache_WAF','burned.tongue_WCF','splinter_WAM','bee.sting_WCM') ~ "white",
                                          injury %in% c('bruised.leg_BAF', 'skinned.knees_BCF','paper.cut_BAM','broken.arm_BCM') ~ "black"),
                           sex = case_when(injury %in% c('stomach.ache_WAF','burned.tongue_WCF','bruised.leg_BAF', 'skinned.knees_BCF') ~ "female",
                                           injury %in% c('splinter_WAM','bee.sting_WCM','paper.cut_BAM','broken.arm_BCM') ~ "male"), 
                           age = case_when(injury %in% c('stomach.ache_WAF','splinter_WAM','bruised.leg_BAF','paper.cut_BAM') ~"adult",
                                           injury %in% c('burned.tongue_WCF','bee.sting_WCM','skinned.knees_BCF','broken.arm_BCM')~"child"))


#6
long6 <- d_6 %>% 
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q41, Q41.5, Q42, Q42.5, Q43, Q43.5, Q44, Q44.5, Q45, Q45.5, Q46, Q46.5, Q47, Q47.5, Q48, Q48.5))

long6b <- long6 %>% mutate(race=case_when(injury %in% c('bruised.leg_WAF','skinned.knees_WCF','burned.tongue_WAM','stomach.ache_WCM') ~ "white",
                                          injury %in% c('broken.arm_BAF','paper.cut_BCF','bee.sting_BAM','splinter_BCM') ~ "black"),
                           sex = case_when(injury %in% c('bruised.leg_WAF','skinned.knees_WCF','broken.arm_BAF','paper.cut_BCF') ~ "female",
                                           injury %in% c('burned.tongue_WAM','stomach.ache_WCM','bee.sting_BAM','splinter_BCM') ~ "male"), 
                           age = case_when(injury %in% c('bruised.leg_WAF','burned.tongue_WAM','broken.arm_BAF','bee.sting_BAM') ~"adult",
                                           injury %in% c('skinned.knees_WCF','stomach.ache_WCM','paper.cut_BCF','splinter_BCM')~"child"))


#7
long7 <- d_7 %>% 
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q49, Q49.5, Q50, Q50.5, Q51, Q51.5, Q52, Q52.5, Q53, Q53.5, Q54, Q54.5, Q55, Q55.5, Q56, Q56.5))

long7b <- long7 %>% mutate(race=case_when(injury %in% c('broken.arm_WAF','paper.cut_WCF','skinned.knees_WAM','bruised.leg_WCM') ~ "white",
                                          injury %in% c('bee.sting_BAF','splinter_BCF','stomach.ache_BAM','burned.tongue_BCM') ~ "black"),
                           sex = case_when(injury %in% c('broken.arm_WAF','paper.cut_WCF','bee.sting_BAF','splinter_BCF') ~ "female",
                                           injury %in% c('skinned.knees_WAM','bruised.leg_WCM','stomach.ache_BAM','burned.tongue_BCM') ~ "male"), 
                           age = case_when(injury %in% c('broken.arm_WAF','skinned.knees_WAM','bee.sting_BAF','stomach.ache_BAM') ~"adult",
                                           injury %in% c('paper.cut_WCF','bruised.leg_WCM','splinter_BCF','burned.tongue_BCM')~"child"))

#8
long8 <- d_8 %>% 
  gather(injury, rating, -c(condition, cp_number, cp_age, cp_sex,
                            Qctrl1, Qctrl1.5, Qctrl2,	Qctrl2.5,	Qctrl3,	Qctrl3.5,	Qctrl4,	Qctrl4.5,
                            Q57, Q57.5, Q58, Q58.5, Q59, Q59.5, Q60, Q60.5, Q61, Q61.5, Q62, Q62.5, Q63, Q63.5, Q64, Q64.5))

long8b <- long8 %>% mutate(race=case_when(injury %in% c('splinter_WAF','bee.sting_WCF','paper.cut_WAM','broken.arm_WCM') ~ "white",
                                          injury %in% c('burned.tongue_BAF','stomach.ache_BCF','skinned.knees_BAM','bruised.leg_BCM') ~ "black"),
                           sex = case_when(injury %in% c('splinter_WAF','bee.sting_WCF','burned.tongue_BAF','stomach.ache_BCF') ~ "female",
                                           injury %in% c('paper.cut_WAM','broken.arm_WCM','skinned.knees_BAM','bruised.leg_BCM') ~ "male"), 
                           age = case_when(injury %in% c('splinter_WAF','paper.cut_WAM','burned.tongue_BAF','skinned.knees_BAM') ~"adult",
                                           injury %in% c('bee.sting_WCF','broken.arm_WCM','stomach.ache_BCF','bruised.leg_BCM')~"child"))

#put all conditions together in long_all?
#realizing if I want injuries to be read across conditions as the same, I need to a factor for that... just rename?
#do renaming in the long_all, so must make it first

# i don't know how to combine them...
# long_all<- gather(long1b, long2b, long3b, long4b, long5b, long6b, long7b, long8b)

#might cheat and download them/combine in excel, then read that in, for in the moment efficiency 
#... doing that



write.csv(long1b,"43long1b.csv", row.names = TRUE)
write.csv(long2b,"43long2b.csv", row.names = TRUE)
write.csv(long3b,"43long3b.csv", row.names = TRUE)
write.csv(long4b,"43long4b.csv", row.names = TRUE)
write.csv(long5b,"43long5b.csv", row.names = TRUE)
write.csv(long6b,"43long6b.csv", row.names = TRUE)
write.csv(long7b,"43long7b.csv", row.names = TRUE)
write.csv(long8b,"43long8b.csv", row.names = TRUE)


#now combine, and load it in....

d_all <- read_excel("~/Desktop/data/43 filtered long.xlsx")
#that works!
#now rename the injuries to not have the demographics on them

#burned tonuge
d_all$injury=recode_factor(d_all$injury,
                           'burned.tongue_WAF'='burned.tongue',
                           'burned.tongue_WCF'='burned.tongue',
                           'burned.tongue_WAM'='burned.tongue',
                           'burned.tongue_WCM'='burned.tongue',
                           'burned.tongue_BAF'='burned.tongue',
                           'burned.tongue_BCF'='burned.tongue',
                           'burned.tongue_BAM'='burned.tongue',
                           'burned.tongue_BCM'='burned.tongue')
#broken arm
d_all$injury=recode_factor(d_all$injury,
                           'broken.arm_WAF'='broken.arm',
                           'broken.arm_WCF'='broken.arm',
                           'broken.arm_WAM'='broken.arm',
                           'broken.arm_WCM'='broken.arm',
                           'broken.arm_BAF'='broken.arm',
                           'broken.arm_BCF'='broken.arm',
                           'broken.arm_BAM'='broken.arm',
                           'broken.arm_BCM'='broken.arm')
#stomach ache
d_all$injury=recode_factor(d_all$injury,
                           'stomach.ache_WAF'='stomach.ache',
                           'stomach.ache_WCF'='stomach.ache',
                           'stomach.ache_WAM'='stomach.ache',
                           'stomach.ache_WCM'='stomach.ache',
                           'stomach.ache_BAF'='stomach.ache',
                           'stomach.ache_BCF'='stomach.ache',
                           'stomach.ache_BAM'='stomach.ache',
                           'stomach.ache_BCM'='stomach.ache')
#paper cut
d_all$injury=recode_factor(d_all$injury,
                           'paper.cut_WAF'='paper.cut',
                           'paper.cut_WCF'='paper.cut',
                           'paper.cut_WAM'='paper.cut',
                           'paper.cut_WCM'='paper.cut',
                           'paper.cut_BAF'='paper.cut',
                           'paper.cut_BCF'='paper.cut',
                           'paper.cut_BAM'='paper.cut',
                           'paper.cut_BCM'='paper.cut')
#skinned knees
d_all$injury=recode_factor(d_all$injury,
                           'skinned.knees_WAF'='skinned.knees',
                           'skinned.knees_WCF'='skinned.knees',
                           'skinned.knees_WAM'='skinned.knees',
                           'skinned.knees_WCM'='skinned.knees',
                           'skinned.knees_BAF'='skinned.knees',
                           'skinned.knees_BCF'='skinned.knees',
                           'skinned.knees_BAM'='skinned.knees',
                           'skinned.knees_BCM'='skinned.knees')
#bruised leg
d_all$injury=recode_factor(d_all$injury,
                           'bruised.leg_WAF'='bruised.leg',
                           'bruised.leg_WCF'='bruised.leg',
                           'bruised.leg_WAM'='bruised.leg',
                           'bruised.leg_WCM'='bruised.leg',
                           'bruised.leg_BAF'='bruised.leg',
                           'bruised.leg_BCF'='bruised.leg',
                           'bruised.leg_BAM'='bruised.leg',
                           'bruised.leg_BCM'='bruised.leg')
#splinter
d_all$injury=recode_factor(d_all$injury,
                           'splinter_WAF'='splinter',
                           'splinter_WCF'='splinter',
                           'splinter_WAM'='splinter',
                           'splinter_WCM'='splinter',
                           'splinter_BAF'='splinter',
                           'splinter_BCF'='splinter',
                           'splinter_BAM'='splinter',
                           'splinter_BCM'='splinter')
#bee sting
d_all$injury=recode_factor(d_all$injury,
                           'bee.sting_WAF'='bee.sting',
                           'bee.sting_WCF'='bee.sting',
                           'bee.sting_WAM'='bee.sting',
                           'bee.sting_WCM'='bee.sting',
                           'bee.sting_BAF'='bee.sting',
                           'bee.sting_BCF'='bee.sting',
                           'bee.sting_BAM'='bee.sting',
                           'bee.sting_BCM'='bee.sting')

#all injuries recorded!
# time to analyze finally??!!

# delete unnecessary columns?? (idk why it had to be split)
d_all<- d_all %>% 
  select( -Q1, -Q1.5, -Q2, -Q2.5, -Q3,-Q3.5, -Q4, -Q4.5, -Q5, -Q5.5, -Q6, -Q6.5, -Q7, -Q7.5, -Q8, -Q8.5)

d_all<- d_all %>% 
  select(-Qctrl1, -Qctrl1.5, -Qctrl2, -Qctrl2.5,-Qctrl3, -Qctrl3.5, -Qctrl4, -Qctrl4.5,
         -Q9, -Q9.5, -Q10, -Q10.5, -Q11, -Q11.5, -Q12, -Q12.5, -Q13, -Q13.5, -Q14,
         -Q14.5, -Q15, -Q15.5, -Q16, -Q16.5,
         -Q17, -Q17.5, -Q18, -Q18.5,-Q19,-Q19.5, -Q20, -Q20.5, -Q21, -Q21.5, -Q22,
         -Q22.5, -Q23, -Q23.5, -Q24, -Q24.5,
         -Q25, -Q25.5, -Q26, -Q26.5, -Q27, -Q27.5, -Q28, -Q28.5, -Q29, -Q29.5, -Q30,
         -Q30.5, -Q31, -Q31.5, -Q32, -Q32.5,
         -Q33, -Q33.5, -Q34, -Q34.5, -Q35, -Q35.5, -Q36, -Q36.5, -Q37, -Q37.5, -Q38,
         -Q38.5, -Q39, -Q39.5, -Q40, -Q40.5,
         -Q41, -Q41.5, -Q42, -Q42.5, -Q43, -Q43.5, -Q44, -Q44.5, -Q45, -Q45.5, -Q46,
         -Q46.5, -Q47, -Q47.5, -Q48, -Q48.5,
         -Q49, -Q49.5, Q50, -Q50.5, -Q51, -Q51.5, -Q52, -Q52.5, -Q53, -Q53.5, -Q54,
         -Q54.5, -Q55, -Q55.5, -Q56, -Q56.5,
         -Q57, -Q57.5, -Q58, -Q58.5,-Q59, -Q59.5, -Q60, -Q60.5, -Q61, -Q61.5, -Q62,
         -Q62.5, -Q63, -Q63.5, -Q64, -Q64.5)

## this is all you'd need to do for reformatting the adult data Brooke
#....

#for dev data/other stuff
#now just add category 'dem' (combo age/sex/race)

d_all <- d_all %>%
  unite("dem", sex, race, age, remove=F) %>% # creates a new variable coding the combination of 3 demographic variables
  mutate(dem = as.factor(dem)) %>%
  mutate(cp_4age = ifelse(cp_age =='4', 1,0),
          cp_5age = ifelse(cp_age =='5', 1,0),
         cp_6age = ifelse(cp_age == '6',1,0)) %>%
  unite("456_ages", cp_4age, cp_5age, cp_6age, remove =F)

## this is all you'd need to do for reformatting data Brooke
#....


# mean ratings across subjects for all combinations of factors 
d.means<- d_all %>%
  group_by(injury, race, sex, age) %>%
  summarize(n=n(),   # n's are uneven; less than they used to be but is it still an issue?
            mean.rating  = mean(rating), 
            sd.rating = sd(rating))

demo.means<- d_all %>%
  group_by(dem) %>%
  summarize(n=n(),   # n's are uneven; less than they used to be but is it still an issue?
            mean.rating  = mean(rating), 
            sd.rating = sd(rating))

# collapsing across injury
d.s <- d_all %>%
  group_by(sex, race, age) %>%
  summarize(n = n(),
            mean.rating  = mean(rating), # note these look quite similar
            sd.rating = sd(rating))

# just male vs female
sex.means <- d_all %>% #opposite of expected: male>female, by 0.4 points (greatest amount w/in dems)
  group_by(sex) %>%
  summarize(n = n(),
            mean.sex = mean(rating),
            median.sex = median(rating)) 

# just white vs black
race.means <- d_all %>% #white>black, onlyby  ~0.2 points avg
  group_by(race) %>%
  summarize(n = n(),
            mean.race = mean(rating),
            median.race = median(rating))

# just adult vs child
age.means <- d_all %>% #still child>adult, but only by ~0.25 points avg?
  group_by(age) %>%
  summarize(n = n(),
            mean.age = mean(rating),
            median.age = median(rating))

# effect of injury 
injury.means <- d_all %>%
  group_by(injury) %>%
  summarize(n=n(),
            mean.inj = mean(rating),
            sd.rating = sd(rating),
            median.inj = median(rating))

# each age group....
kid_ages.means <- d_all %>%
  group_by(cp_age) %>%
  summarize(n = n(),
            mean.age = mean(rating),
            sd.rating = sd(rating),
            median.age = median(rating))
# now linear models
#unlike 'w katie data june 15' I have current exclusions here

#"pretending rating is continuous, not ordinal, which isn't true"
lm1 <- lmer(rating ~ injury + sex + race + age + (1|cp_number), data=d_all)
summary(lm1)
Anova(lm1, Type=3)
  #nothing significant.... oddly sex and race more signif than age....

#controlling for injury (basically same as lm1)
lm2 <- lmer(rating ~ sex + race + age + (1|injury) + (1|cp_number), data=d_all)
summary(lm2)
Anova(lm2)
#no main effects significant

#injury interaction checks:
  # doing an interaction of age:injury
lm3 <- lmer(rating ~ injury * age + race + sex + (1|cp_number), data=d_all)
summary(lm3)
Anova(lm3, Type=3)
  # interaction of injury and age, p=0.067.... ALMOST significant
  # how do i graph this?

  #check race:injury...
lm4 <- lmer(rating ~ injury * race + age + sex + (1|cp_number), data=d_all)
summary(lm4)
Anova(lm4, Type=3)
#nope... 0.2

  #sex:injury
lm5 <- lmer(rating ~ injury * sex + race + age + (1|cp_number), data=d_all)
summary(lm5)
Anova(lm5, Type=3)
#def not... 0.8

#holding injury as a constant/ demographic interaction?
lm6 <- lmer(rating ~ race * age * sex + (1|cp_number) + (1|injury), data=d_all)
summary(lm6)
Anova(lm6, Type=3)
  # no 2 or 3 way interactions
  #closest to significant are sex main effect (0.21) and interaction of race/age (0.20)

#check child's age effects....

lm7 <- lmer(rating ~ sex + race + age + cp_age + (1|injury) + (1|cp_number), data=d_all)
summary(lm7)
Anova(lm7) #cp age = p=0.432

#child age interactions?

lm8 <- lmer(rating ~ cp_age * sex * race * age + (1|injury) + (1|cp_number), data=d_all)
summary(lm8)
Anova(lm8) #ok so many interactions analyzed for... one foudn
# significant is cp_age:sex:age... so sex/age interaction significant for some child ages not others..

#each age seperately

#4 y/os main effects
lm_fours1  <- lmer(rating ~ cp_4age + sex + race + age + (1|injury) + (1|cp_number), data=d_all)
summary(lm_fours1)
Anova(lm_fours1)
  #include injury/rating
lm_fours2  <- lmer(rating ~ cp_4age + sex + race + age + injury + (1|cp_number), data=d_all)
summary(lm_fours2)
Anova(lm_fours2) #injury has significant effect, at least

# 5 y/os main effects
lm_fives1  <- lmer(rating ~ cp_5age + sex + race + age + (1|injury) + (1|cp_number), data=d_all)
summary(lm_fives1)
Anova(lm_fives1)
  #include injury/rating
lm_fives2  <- lmer(rating ~ cp_5age + sex + race + age + injury + (1|cp_number), data=d_all)
summary(lm_fives2)
Anova(lm_fives2) #injury significant for 4s and 5s... nothing else


#### can't yet do interactions of child sex/character sex
####same w participant race (can we get this w lab school kids?)
# return to this...... but now viz

#data viz
library(tidyverse)
library(patchwork)

#using old code first:
gc <- ggplot(d_all, aes(dem, rating)) + #here see 5's rate same avg across character demographics...
  facet_wrap(~ cp_age) +
  geom_boxplot(aes(fill=factor(dem))) + 
  labs(x="demographic category (sex-race-age)",
       y="pain rating")
gc

gc2 <- ggplot(d_all, aes(injury, rating)) + #5's show higher broken arm/skinned knees...also lower stomach ache/burned tongue
  facet_wrap(~ cp_age) +
  geom_boxplot(aes(fill=factor(injury))) + 
  labs(x="demographic category (sex-race-age)",
       y="pain rating")
gc2

# which is the bar plot of all injuries?
