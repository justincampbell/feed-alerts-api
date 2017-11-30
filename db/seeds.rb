include FactoryBot::Syntax::Methods

create :user

create :feed,
  name: "WOD &#8211; CrossFit West Chester",
  url: "http://crossfitwc.com/category/wod/feed/"

create :feed,
  name: "WOD &#8211; CrossFit Mayhem",
  url: "http://www.crossfitmayhem.com/category/wod/feed/"

create :feed,
  name: "Workout Of The Day &#8211; Invictus | Redefining Fitness",
  url: "http://www.crossfitinvictus.com/category/wod/feed/"

create :feed,
  name: "Fitness &#8211; Invictus | Redefining Fitness",
  url: "http://www.crossfitinvictus.com/category/wod/fitness/feed/"

create :feed,
  name: "Workout Of The Day &#8211; Invictus | Redefining Fitness",
  url: "http://www.crossfitinvictus.com/category/wod/competition/feed/"

create :feed,
  name: "Workout of the Day - Subversus Fitness",
  url: "https://www.subversusfitness.com/workout-of-the-day"
