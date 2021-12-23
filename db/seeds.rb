# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'spicy-proton'
gen = Spicy::Proton.new

N_FOLDERS = 5
N_NOTES = 15
N_TAGS_PER_NOTE = 2

content = [
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed turpis nulla, commodo in quam dignissim, condimentum facilisis quam. Sed non arcu quis eros posuere faucibus. Ut bibendum metus non magna convallis pharetra. Etiam orci metus, rutrum eget neque non, mattis scelerisque arcu. Cras efficitur ultricies ornare. Vivamus ornare placerat purus non dignissim. Cras et tellus aliquet, tincidunt quam quis, sagittis risus. Vestibulum non aliquam elit. In ullamcorper sodales elementum. Cras nec augue rutrum, iaculis nulla a, imperdiet felis. Suspendisse potenti. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis magna felis, condimentum a dolor ut, molestie malesuada ante. Integer molestie lectus a ligula euismod, ac tristique nibh accumsan. Suspendisse pretium interdum purus, in dapibus dui lobortis a.",
  "Suspendisse eu lacus felis. Nam nec augue condimentum diam convallis varius vel et sem. Suspendisse malesuada nulla dui, ac cursus risus fermentum et. Donec vitae pellentesque nisi. Nam porta nisl sit amet nisi auctor, a ornare magna laoreet. Integer molestie ligula malesuada tincidunt rutrum. Quisque pulvinar gravida nisl non elementum. Nulla eget elit sed ipsum fermentum pharetra. Nulla facilisi. Aliquam sit amet tellus non neque pellentesque vulputate ut in ipsum. Donec a orci varius, faucibus libero et, pulvinar mauris. Cras eu sapien quam. Donec pulvinar sagittis nisl. Pellentesque at porttitor est. Nunc elementum turpis at justo ornare, id vehicula ante imperdiet. Ut et eleifend urna.",
  "Quisque vehicula tortor purus, non tempor tellus tempor nec. Vivamus maximus eget leo eu sollicitudin. Vivamus volutpat ultricies felis, euismod hendrerit ligula finibus id. Phasellus sed felis vitae arcu fermentum finibus ut quis elit. Nunc nec leo eu erat lacinia porta. Nullam mauris felis, interdum quis nibh sit amet, euismod luctus sapien. Nunc at erat diam. Fusce rhoncus ornare sem, in ultrices ante sodales a. Pellentesque vel nulla nec felis pellentesque interdum sed nec risus. Proin sed est non odio finibus congue a sit amet libero.",
  "Ut tincidunt arcu a justo elementum, non tincidunt enim dictum. Maecenas vehicula quam at viverra vulputate. Vestibulum maximus convallis tincidunt. Mauris metus ipsum, lacinia eu finibus vel, fringilla non est. Vivamus porta vulputate ipsum id iaculis. Duis auctor at risus interdum aliquet. Suspendisse blandit ullamcorper arcu nec aliquam. Phasellus efficitur tincidunt porta. Mauris accumsan, metus et tempor condimentum, ipsum sapien posuere nunc, sit amet hendrerit augue tortor at nisi. Donec dictum ligula sit amet erat rutrum blandit. Interdum et malesuada fames ac ante ipsum primis in faucibus.",
  "Pellentesque vulputate nec elit sit amet egestas. Duis ac lacus mattis enim aliquam ullamcorper in quis dolor. Integer convallis lorem in justo interdum, et rhoncus quam rhoncus. Pellentesque laoreet eros non risus tempor consectetur. Curabitur dictum magna lacus, at semper mauris imperdiet eu. Nulla sollicitudin mi non metus auctor malesuada. Quisque ornare odio ut volutpat varius. Ut eu interdum nisl. Ut id aliquam est. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Phasellus vehicula, tellus a gravida lacinia, erat elit finibus ante, ut sollicitudin justo ipsum sit amet enim. Maecenas ornare tincidunt pretium."
]

user = User.create(email: "note-thing@pm.me", password: "1234")

N_FOLDERS.times do
  Folder.create(title: gen.adjective, user: user)
end


N_NOTES.times do
  ct = content[rand(0..(content.length - 1))]
  Note.create(title: gen.noun, body: ct, folder: Folder.find(rand(1..N_FOLDERS)))
end



# ajoute N_TAGS_PER_NOTE tags par note
for i in 1..N_NOTES do
  for _ in 1..N_TAGS_PER_NOTE do
    t = Tag.new(title: gen.adverb)
    t.save
    t.note_tags.create({note_id: i})

  end


end