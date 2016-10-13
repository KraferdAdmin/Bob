//: Playground - noun: a place where people can play

import UIKit


enum IndustryCategory{
    case Restaurant
    case GeneralLabor
    case NonSpecific
}

struct Experience{
    var industry: IndustryCategory
    var monthsOfExperience: Int
    
    mutating func addExperience(newExperience: Experience){
        self.monthsOfExperience += newExperience.monthsOfExperience
    }
}

typealias QualifySignature = (Applicant, IndustryCategory) -> Bool

struct QualificationManger{
    static let sharedInstance = QualificationManger()
    private init(){}
}

class IndustryManager{
    
    static let sharedInstance = IndustryManager()
    
    var industries = [Industry]()
    
    private init(){}
    
    func sortIndustryByRant() -> [Industry]{
        return industries.sorted{
            (industry1: Industry, industry2: Industry) in
            return industry1.rank > industry2.rank
        }
    }
}

struct IndustryToEmployeePointManger{
    var industryPoints: [IndustryCategory: Int]
    
    mutating func addPoints(industry: IndustryCategory, points: Int){
        if industryPoints[industry] != nil{
            industryPoints[industry]! += points
        }else{
            industryPoints[industry] = points
        }
    }
    
    mutating func computeEmplyeeExperiencePoints(applicant: Applicant){
        let experience = applicant.workExperience
        
        for job in experience{
            industryPoints[job.industry] = job.monthsOfExperience
        }
    }
    
    mutating func getHighestPointIndustry()-> IndustryCategory?{

        var maxPointIndustry: IndustryCategory?
        var highestPoints = 0
        
        for industryPointDictionary in industryPoints{
            
            if industryPointDictionary.1 > highestPoints{
                maxPointIndustry = industryPointDictionary.0
                highestPoints = industryPointDictionary.1
            }
        }
        
        return maxPointIndustry
    }
}

struct Qualification{
    
    var qualifications: [QualifySignature]
    
    mutating func addQualification(qualification: @escaping QualifySignature){
        qualifications.append(qualification)
    }
    
    func checkQualifications(applicant: Applicant, with industry: IndustryCategory) -> Bool{
        var isQualified = true
        
        for qualification in qualifications{
            
            if qualification(applicant, industry) == false{
                isQualified = false
                break
            }
        }
        
        return isQualified
    }
    
    init(){
        self.qualifications = [QualifySignature]()
    }
}

struct Industry{
    static let prestigeConstant = 2
    static let demandConstant = 1
    let industryCategory: IndustryCategory
    var prestige: Int
    var demand: Int
    var qualification: Qualification
    
    var rank: Int{
        get{
            return prestige * Industry.prestigeConstant + demand * Industry.demandConstant
         }
    }
    
    func checkIfApplicationIsQualified(applicant: Applicant) -> Bool{
        
        var isQualified = true
        
        isQualified = qualification.checkQualifications(applicant: applicant, with: industryCategory)
        
        return isQualified
    }
    
    init(industryCategory: IndustryCategory, prestige: Int, demand: Int, qualification: Qualification = Qualification()){
        self.industryCategory = industryCategory
        self.prestige = prestige
        self.demand = demand
        self.qualification = qualification
    }
}

struct Applicant{
    let age = 18
    var workExperience: [Experience]
    var preferredIndustry: IndustryCategory
    var totalMonthsOfWorkExperience: Int{
        var monthsOfExperienceTotal = 0
        for experience in workExperience{
            monthsOfExperienceTotal += experience.monthsOfExperience
        }
        return monthsOfExperienceTotal
    }
    
    mutating func addExperience(experience: Experience){
        workExperience = workExperience.map{
            if $0.industry == experience.industry{
                return Experience(industry: $0.industry, monthsOfExperience: $0.monthsOfExperience + experience.monthsOfExperience)
            }else{
                return $0
            }
        }
    }
    
    func getIndustryWithHighestExperience() -> IndustryCategory{
        
        if let jobOne = workExperience.first{
        
            let industry =  workExperience.reduce(jobOne){
                (highestExperience: Experience, nextExperience: Experience) in
                
                if highestExperience.monthsOfExperience >= nextExperience.monthsOfExperience{
                    
                    return highestExperience
                }else{
                    return nextExperience
                }
            }
            
            return industry.industry
        }else{
            return IndustryCategory.NonSpecific
        }
        
    }
    
    func sortIndustyByExperience() -> [Experience]{
        return workExperience.sorted{
            (job1: Experience, job2: Experience) in
            return job1.monthsOfExperience > job2.monthsOfExperience
        }
    }
}

// Start of Test Senario 

// Create Industries
let industryManager = IndustryManager.sharedInstance

var generalLabor = Industry(industryCategory: .GeneralLabor, prestige: 5, demand: 5)

var grocer = Industry(industryCategory: .Restaurant, prestige: 3, demand: 2)

industryManager.industries.append(generalLabor)
industryManager.industries.append(grocer)

// Add Qualificaions for Industries 

// Check if applicant has 6 months experience or more
generalLabor.qualification.addQualification{
    (applicant: Applicant, industryCategory: IndustryCategory) in
    
    var monthsOfExperienceInIndustry = 0
    
    for experience in applicant.workExperience{
        if experience.industry == industryCategory{
            monthsOfExperienceInIndustry = experience.monthsOfExperience
            
            if monthsOfExperienceInIndustry > 5{
                return true
            }
        }
    }
    
    return false
}

// Check if applicant is 18 or orlder
generalLabor.qualification.addQualification {
    (applicant, industryCategory) -> Bool in
    if applicant.age > 17{
        return true
    }else{
        return false
    }
}

generalLabor.qualification.addQualification{
    (applicant: Applicant, industryCategory: IndustryCategory) in
    
    if applicant.totalMonthsOfWorkExperience > 3{
        return true
    }else{
        return false
    }
}
//end

// Create applicant and experience
let bobExperience1 = Experience(industry: .GeneralLabor, monthsOfExperience: 6)
let bobExperience2 = Experience(industry: .Restaurant, monthsOfExperience: 12)

let bobsExperience = [bobExperience1, bobExperience2]

let bob = Applicant(workExperience: bobsExperience, preferredIndustry: .GeneralLabor)
// end

grocer.checkIfApplicationIsQualified(applicant: bob)

generalLabor.checkIfApplicationIsQualified(applicant: bob)

print(bob.sortIndustyByExperience().first)

var pointManager = IndustryToEmployeePointManger(industryPoints: [:])

pointManager.computeEmplyeeExperiencePoints(applicant: bob)

pointManager.addPoints(industry: grocer.industryCategory, points: grocer.rank)

pointManager.addPoints(industry: generalLabor.industryCategory, points: generalLabor.rank)

print(pointManager.industryPoints)

print(pointManager.getHighestPointIndustry())
