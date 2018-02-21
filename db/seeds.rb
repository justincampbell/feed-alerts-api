include FactoryBot::Syntax::Methods

create :user

cfwc = create(
  :feed,
  name: "WOD - CrossFit West Chester",
  url: "http://crossfitwc.com/category/wod/feed/"
)

create :feed_item,
  feed: cfwc,
  title: "WOD 1/2/30",
  content: "30 Deadlifts"

create :feed,
  name: "WOD - CrossFit Mayhem",
  url: "http://www.crossfitmayhem.com/category/wod/feed/"

create :feed,
  name: "Workout Of The Day - Invictus | Redefining Fitness",
  url: "http://www.crossfitinvictus.com/category/wod/feed/"

create :feed,
  name: "Fitness - Invictus | Redefining Fitness",
  url: "http://www.crossfitinvictus.com/category/wod/fitness/feed/"

create :feed,
  name: "Workout Of The Day - Invictus | Redefining Fitness",
  url: "http://www.crossfitinvictus.com/category/wod/competition/feed/"

create :feed,
  name: "Workout of the Day - Subversus Fitness",
  url: "https://www.subversusfitness.com/workout-of-the-day"
