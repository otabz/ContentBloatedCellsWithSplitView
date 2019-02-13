//
//  Vaccination.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/11/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import Foundation

class Vaccinations {
    
    static fileprivate let list = [
        // stage - 0
        Stage(id: "0", at: At.At_00Birth, descEn: At.At_00Birth.rawValue, descAr: "عند الولادة", symbol: "stage0", vaccines: [
            Vaccine(id: "0", nameEn: "BCG", nameAr: "الدرن", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "Hepatitis B", nameAr: "التهاب الكبد ب", descEn: "", descAr: "")
            ]),
        
        // stage - 1
        Stage(id: "1", at: At.At_02Months, descEn: At.At_02Months.rawValue, descAr: "أشهر ٢", symbol: "stage1", vaccines:[
            Vaccine(id: "0", nameEn: "IPV", nameAr: "شلل اطفال معطل", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "DTap", nameAr: "الثلاتي البكتيري", descEn: "", descAr: ""),
            Vaccine(id: "2", nameEn: "Hepatitis B", nameAr: "التهاب الكبد ب", descEn: "", descAr: ""),
            Vaccine(id: "3", nameEn: "HIB", nameAr: "المستديمة النزلية", descEn: "", descAr: ""),
            Vaccine(id: "4", nameEn: "Pneumococcal Conjugate (PCV)", nameAr: "البكتيريا العقدية لرمؤية", descEn: "", descAr: ""),
            Vaccine(id: "5", nameEn: "Rota", nameAr: "فيروس الروتا", descEn: "", descAr: "")
            ]),
        
        // stage - 2
        Stage(id: "2", at: At.At_04Months, descEn: At.At_04Months.rawValue, descAr: "أشهر ٤", symbol: "stage2", vaccines:[
            Vaccine(id: "0", nameEn: "IPV", nameAr: "شلل اطفال معطل", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "DTap", nameAr: "الثلاتي البكتيري", descEn: "", descAr: ""),
            Vaccine(id: "2", nameEn: "Hepatitis B", nameAr: "التهاب الكبد ب", descEn: "", descAr: ""),
            Vaccine(id: "3", nameEn: "HIB", nameAr: "المستديمة النزلية", descEn: "", descAr: ""),
            Vaccine(id: "4", nameEn: "Pneumococcal Conjugate (PCV)", nameAr: "البكتيريا العقدية لرمؤية", descEn: "", descAr: ""),
            Vaccine(id: "5", nameEn: "Rota", nameAr: "فيروس الروتا", descEn: "", descAr: "")
            ]),
        
        // stage - 3
        Stage(id: "3", at: At.At_06Months, descEn: At.At_06Months.rawValue, descAr: "أشهر ٦", symbol: "stage3", vaccines:[
            Vaccine(id: "0", nameEn: "OPV", nameAr: "شلل الاطفال الفموي", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "IPV", nameAr: "شلل اطفال معطل", descEn: "", descAr: ""),
            Vaccine(id: "2", nameEn: "DTap", nameAr: "الثلاتي البكتيري", descEn: "", descAr: ""),
            Vaccine(id: "3", nameEn: "Hepatitis B", nameAr: "التهاب الكبد ب", descEn: "", descAr: ""),
            Vaccine(id: "4", nameEn: "HIB", nameAr: "المستديمة النزلية", descEn: "", descAr: ""),
            Vaccine(id: "5", nameEn: "Pneumococcal Conjugate (PCV)", nameAr: "البكتيريا العقدية لرمؤية", descEn: "", descAr: "")
            ]),
        
        // stage - 4
        Stage(id: "4", at: At.At_09Months, descEn: At.At_09Months.rawValue, descAr: "أشهر ٩", symbol: "stage4", vaccines:[
            Vaccine(id: "0", nameEn: "Measles", nameAr: "الحصبة المفرد", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "Meningococcal Conjugate Quadrivalent (MCV4)", nameAr: "الحمى الشوكية الرباعي المقترن", descEn: "", descAr: ""),
            ]),
        
        // stage - 5
        Stage(id: "5", at: At.At_12Months, descEn: At.At_12Months.rawValue, descAr: "", symbol: "stage5", vaccines:[
            Vaccine(id: "0", nameEn: "OPV", nameAr: "شلل الاطفال الفموي", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "MMR", nameAr: "الثلاثي الفيروسي", descEn: "", descAr: ""),
            Vaccine(id: "2", nameEn: "Pneumococcal Conjugate (PCV)", nameAr: "البكتيريا العقدية لرمؤية", descEn: "", descAr: ""),
            Vaccine(id: "3", nameEn: "Meningococcal Conjugate Quadrivalent (MCV4)", nameAr: "الحمى الشوكية الرباعي المقترن", descEn: "", descAr: "")
            ]),
        
        // stage - 6
        Stage(id: "6", at: At.At_18Months, descEn: At.At_18Months.rawValue, descAr: "أشهر ١٨", symbol: "stage6", vaccines:[
            Vaccine(id: "0", nameEn: "OPV", nameAr: "شلل الاطفال الفموي", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "DTap", nameAr: "الثلاتي البكتيري", descEn: "", descAr: ""),
            Vaccine(id: "2", nameEn: "HIB", nameAr: "المستديمة النزلية", descEn: "", descAr: ""),
            Vaccine(id: "3", nameEn: "MMR", nameAr: "الثلاثي الفيروسي", descEn: "", descAr: ""),
            Vaccine(id: "4", nameEn: "Varicella", nameAr: "الجديري المائي", descEn: "", descAr: ""),
            Vaccine(id: "5", nameEn: "Hepatitis A", nameAr: "إلتهاب الكبد أ", descEn: "", descAr: "")
            ]),
        
        // stage - 7
        Stage(id: "7", at: At.At_24Months, descEn: At.At_24Months.rawValue, descAr: "أشهر ٢٤", symbol: "stage7", vaccines:[
            Vaccine(id: "0", nameEn: "Hepatitis A", nameAr: "إلتهاب الكبد أ", descEn: "", descAr: "")
            ]),

        // stage - 8
        Stage(id: "8", at: At.At_46Years, descEn: At.At_46Years.rawValue, descAr: "سنوات ٤-٦", symbol: "stage8", vaccines:[
            Vaccine(id: "0", nameEn: "OPV", nameAr: "شلل الاطفال الفموي", descEn: "", descAr: ""),
            Vaccine(id: "1", nameEn: "DTaP (Td)", nameAr: "(الثلاثي البكتيري (الثنائي البكتيري", descEn: "", descAr: ""),
            Vaccine(id: "2", nameEn: "MMR", nameAr: "الثلاثي الفيروسي", descEn: "", descAr: ""),
            Vaccine(id: "3", nameEn: "Varicella", nameAr: "(الجديري المائي (العنقز", descEn: "", descAr: "")
            ])
    ]
    
    static func stages() -> [Stage] {
        return list
    }
    
    static func details(_ vaccine: String!) -> String {
        if vaccine == "DTap" {
            return "The DTaP vaccine is 3 vaccines in 1 shot. It protects against diphtheria, tetanus and pertussis. It's given as a series of 5 shots, the first when your child is 2 months old and the last when they are 4- to 6 years old. Diphtheria is a disease that attacks the throat and heart. It can lead to heart failure and death. Tetanus is also called 'lockjaw.' It can lead to severe muscle spasms and death. Pertussis (also called 'whooping cough') causes severe coughing that makes it hard to breathe, eat, and drink. It can lead to pneumonia, convulsions, brain damage, and death. Having your child immunized when he or she is young (which means making sure he or she gets all of the DTaP shots) protects your child against these diseases for about 10 years. After this time, your child will need booster shots."
        }
        else if vaccine == "Rota" {
            return "The rotavirus vaccine protects against rotavirus. Your child will receive either a two-dose, at 2 and 4 months of age, or a three-dose series, at 2, 4, and 6 months of age, depending on what your doctor recommends. All doses should be given by no later than age 8 months of age. Rotavirus is a virus that causes diarrhea, mostly in babies and young children. The diarrhea can be severe and cause dehydration. Rotavirus can also cause vomiting and fever in babies. After rotavirus vaccination, call your family doctor if your child has stomach pain with severe crying (which may be brief), vomiting, blood in the stool, or is acting weak or very irritable. This is especially important within the first seven days after rotavirus vaccination. Contact your doctor if your child has any of these signs, even if it has been several weeks since the last dose of vaccine."
        }
        else if vaccine == "IPV" {
            return "The IPV (inactivated polio virus) vaccine helps prevent polio. Polio is an infectious disease caused by a virus that lives in the throat and intestinal tract. It is most often spread through person-to-person contact with the stool of an infected person and may also be spread through oral/nasal secretions. It's given four times as a shot, from age 2 months to 6 years. Polio can cause muscle pain and paralysis of one or both legs or arms. It may also paralyze the muscles used to breathe and swallow. It can lead to death."
        }
        else if vaccine == "MMR" {
            return "The MMR vaccine protects against the measles, mumps, and rubella (MMR). The measles cause fever, rash, cough, runny nose, and watery eyes. It can also cause ear infections and pneumonia. Measles can also lead to more serious problems, such as brain swelling and even death. The mumps cause fever, headache, and painful swelling of one or both of the major saliva glands. Mumps can lead to meningitis (infection of the coverings of the brain and spinal cord) and, very rarely, to brain swelling. Rarely, it can cause the testicles of boys or men to swell, which can make them unable to have children. Rubella is also called the German measles. It causes a slight fever, a rash and swelling of the glands in the neck. Rubella can also cause brain swelling or a problem with bleeding. If a pregnant woman catches rubella, it can cause her to lose her baby or have a baby who is blind or deaf, or has trouble learning. Some people have suggested that the MMR vaccine causes autism. However, research has shown that there is no link between autism and childhood vaccinations."
        }
        else if vaccine == "HIB" {
            return "The Hib vaccine helps prevent Haemophilus influenza type b, a leading cause of serious illness in children. It can lead to meningitis, pneumonia and a severe throat infection. The Hib vaccine is given as a series of 3 or 4 shots, from age 2 months to 15 months."
        }
        else if vaccine == "Varicella" {
            return "The varicella vaccine helps prevent chickenpox. It is given to children once after they are 12 months old and again at 4 to 6 years old, or to older children if they have never had chickenpox or been vaccinated."
        }
        else if vaccine == "Pneumococcal Conjugate (PCV)" {
            return "The pneumococcal conjugate vaccine (PCV) protects against a type of bacteria that is a common cause of ear infections. This type of bacteria can also cause more serious illnesses, such as meningitis and bacteremia (infection in the blood stream). Infants and toddlers are given 4 doses of the vaccine at 2, 4, 6, and 12 months of age. The vaccine may also be used in older children who are at risk for pneumococcal infection."
        }
        else if vaccine == "Meningococcal Conjugate Quadrivalent (MCV4)" {
            return "The meningococcal conjugate vaccine (MCV4) protects against four strains ('types') of bacterial meningitis caused by the bacteria N. meningitidis. Bacterial meningitis is an infection of the fluid around the brain and spinal cord. It is a serious illness that can cause high fever, headache, stiff neck, and confusion. It can also cause more serious complications, such as brain damage, hearing loss, or blindness."
        }
        else if vaccine == "Hepatitis B" {
            return "The HBV vaccine helps prevent hepatitis B virus (HBV) infection, an infection of the liver that can lead to liver cancer and death. The vaccine is given as a series of 3 shots, with the first shot given soon after birth."
        }
        else if vaccine == "DTaP (Td)" {
            return "The Tdap vaccine is used as a booster to the DTaP vaccine. It helps prevent tetanus, diphtheria, and pertussis."
        }
        else if vaccine == "BCG" {
            return "If it's advised that your baby has the BCG vaccine, the injection is usually offered soon after birth, while your baby is still in hospital. Alternatively, your baby can be referred to a local healthcare centre for vaccination after they've left hospital. This may not necessarily be the local GP surgery, as not all surgeries can provide this service. If you are offered BCG vaccination as an adult, it will be arranged by a local healthcare centre."
        }
        else if vaccine == "OPV" {
            return "The OPV (oral polio virus) vaccine helps prevent polio. Polio is an infectious disease caused by a virus that lives in the throat and intestinal tract. It is most often spread through person-to-person contact with the stool of an infected person and may also be spread through oral/nasal secretions."
        }
        else if vaccine == "Measles" {
            return "Measles is the most deadly of all childhood rash/fever illnesses. The disease spreads very easily, so it is important to protect against infection. To prevent measles, children (and some adults) should be vaccinated with the measles, mumps, and rubella (MMR) vaccine."
        }
        else if vaccine == "Hepatitis A" {
            return "Hepatitis A is a liver disease caused by the hepatitis A virus (HAV). Hepatitis A can affect anyone. Vaccines are available for long-term prevention of HAV infection in persons 1 year of age and older. Good personal hygiene and proper sanitation can also help prevent the spread of hepatitis A."
        }
            
        else {
            return ""
        }
    }
    
    static func show() {
        for each in list {
            print("id: \(each.id) / desc_en: \(each.descEn) / desc_ar: \(each.descAr)\n")
            for sub in each.vaccines {
               print("  id: \(sub.id) / name_en: \(sub.nameEn) / name_ar: \(sub.nameAr)\n")
            }
        }
    }
    
    class Stage {
        let id: String
        let at: At
        let descEn: String
        let descAr: String
        let symbol: String
        let vaccines: [Vaccine]
        
        required init(id: String, at: At, descEn: String, descAr: String, symbol: String, vaccines: [Vaccine]) {
            self.id = id
            self.at = at
            self.descEn = descEn
            self.descAr = descAr
            self.symbol = symbol
            self.vaccines = vaccines
        }
    }
    
    class Vaccine {
        let id: String
        let nameEn: String
        let nameAr: String
        let descEn: String
        let descAr: String
        
        required init(id: String, nameEn: String, nameAr: String, descEn: String, descAr: String) {
            self.id = id
            self.nameEn = nameEn
            self.nameAr = nameAr
            self.descEn = descEn
            self.descAr = descAr
        }
    }
    
}
enum At : String {
    case At_00Birth = "At Birth"
    case At_02Months = "2 Months"
    case At_04Months = "4 Months"
    case At_06Months = "6 Months"
    case At_09Months = "9 Months"
    case At_12Months = "12 Months"
    case At_18Months = "18 Months"
    case At_24Months = "24 Months"
    case At_46Years = "4-6 Years"
}

