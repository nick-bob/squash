# Q3. System design and Implementation

Please​ implement​ a URL​ shortener​ service (e.g. ​https://bitly.com/​)

### Implement​ a simple​ bit.ly​ like​ service,​ name​ the following​ 2 RESTful​ endpoints

1. RESTful​ endpoint​ for​ url​ submission
```
POST /newurl                    
    -  Request: { "url": "​https://www.google.com​" }                
    -  Response: { "url": "​https://www.google.com​", "shortenUrl":"https://shortenurl.org/g20hi3k9"}
```
2. Shorten​ redirect​ URL
```
GET​ /[a-zA-Z0-9]{9}​ (regex,​ eg.​ g20hi3k9)
- HTTP​ 304​ to​ saved​ link​ (eg.​ https://www.google.com​​ according previous​ example)
```

- No update on the shorten link once created

### System​ design​ concern
                                                 
* High availability​:​ Please​ make​ it​ highly available and​ no​ single​ point​ ​of failure.
* Scalability​ :​ Please​ make​ it​ scalable.
* Scaling​ target​:​ 1000+​ req/s,​ after​ scaling-up/out without​ major​ code​ change

### Tech stack

* You​ could choose​ any​ technology​ / programming​ language​ / database​ / cache​ / AWS​ services,​ as​ long​ as​ ​the application​ code​ is​ executable​ on​ generic​ Linux EC2​ node​ and​ ​the whole​ setup​ fits​ in​ AWS​ environment.

### Deliverable​ & Documentation

* The​ application​ deliverable​ should​ be​ self-contained,​ preferably​ an​ automated deployment​ package / container image,​ such​ that​ we​ can​ deploy​ it​ easily                           
* The​ system/infrastructure​ should​ be​ also​ documented​ OR​ automated​ (via​ e.g. shell​ script)                               
* Both​ ​the system​ design​ and ​the actual​ system​ infrastructure​ configuration​ are the key​ measurement​ ​of this​ question.                                                             
* Please​ briefly​ explain​ your​ system​ and​ say​ why​ you​ are going​ to​ implement like​ that.
* Please​ state​ any​ assumption​ and​ limitation​ of​ ​the system​ implemented.