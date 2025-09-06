from nexy import Component

@Component(
   imports=[LinkCard,Badge]
)
def View():

	return {"name": "hello world"}

