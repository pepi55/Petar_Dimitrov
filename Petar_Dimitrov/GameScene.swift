/* GameScene.swift
 * Petar_Dimitrov
 *
 * Created by Petar Dimitrov on 4/16/15.
 * Copyright (c) 2015 Astute Monkey Studio. All rights reserved.
 */

import SpriteKit
import CoreMotion

class CustomSprite: SKSpriteNode {
	internal var counter: CGFloat = 0
	internal var spawn: Bool = true
	internal var spawnLocation = CGPoint()
}

class GameScene: SKScene {
	//Row locations from L to R
	let rowLocations = [
		//[CGPoint(x: 210, y: 530), CGPoint(x: 0, y: 520)],			//ROW 1
		[CGPoint(x: 400, y: 530), CGPoint(x: 0, y: 340)],				//ROW 2
		[CGPoint(x: 460, y: 530), CGPoint(x: 85, y: 0)],				//ROW 3
		[CGPoint(x: 540, y: 530), CGPoint(x: 920, y: 0)],				//ROW 4
		[CGPoint(x: 615, y: 530), CGPoint(x: 1024, y: 345)],		//ROW 5
		//[CGPoint(x: 790, y: 530), CGPoint(x: 1024, y: 520)]		//ROW 6
	]

	let motionManager = CMMotionManager()
	let queue = NSOperationQueue()

	//n * 10% chance NOT to spawn grass
	var spawnChance: UInt32 = 9

	let scoreBoard = SKLabelNode(fontNamed: "Chalkduster")
	internal var score: Int = 0

	var ball: SKSpriteNode!
	var enemies = [CustomSprite]()
	var grassRows = [Array<CustomSprite>]()

	override func didMoveToView(view: SKView) {
		/* Background */
		var background = createSpriteAt(sprite: "Background", location: CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)))
		self.addChild(background)
		/* Background */

		/* Grass */
		for var i = 0; i < rowLocations.count; ++i {
			grassRows.append([CustomSprite]())

			for var j = 0; j < 10; ++j {
				grassRows[i].append(createSpriteAt(sprite: "Grass_2", location: CGPoint()))
				grassRows[i][j].name = "Grass"
				grassRows[i][j].counter = CGFloat(j);
				grassRows[i][j].spawn = arc4random_uniform(10) >= spawnChance
				grassRows[i][j].spawnLocation = rowLocations[i][0]
				grassRows[i][j].texture = (arc4random_uniform(2) >= 1) ? SKTexture(imageNamed: "Grass_1") : SKTexture(imageNamed: "Grass_2")

				self.addChild(grassRows[i][j])
			}
		}
		/* Grass */

		/* Ball */
		ball = createSpriteAt(sprite: "Ball", location: CGPoint(x: self.frame.width / 2, y: 100))
		ball.setScale(0.5)
		self.addChild(ball)
		/* Ball */

		/* Score */
		scoreBoard.fontSize = 32
		scoreBoard.position = CGPoint(x: 170, y: 575)
		scoreBoard.text = String(score)
		self.addChild(scoreBoard)
		/* Score */

		/* Enemies */
		for var i = 0; i < 2; ++i {
			enemies.append(createSpriteAt(sprite: "Character_L", location: CGPoint()))
			enemies[i].name = "Character_L"
			enemies[i].setScale(0.7)
			enemies[i].counter = CGFloat(i)
			enemies[i].spawnLocation = CGPoint(x: ball.position.x, y: CGFloat((arc4random_uniform(UInt32(self.frame.height / 2)))) + (self.frame.height / 2))

			self.addChild(enemies[i])
		}
		/* Enemies */
	}

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		/* Called when a touch begins */
		goToHelpScene()
	}

	override func update(currentTime: CFTimeInterval) {
		/* Grass */
		for var i = 0; i < grassRows.count; ++i {
			for var j = 0; j < grassRows[i].count; ++j {
				if grassRows[i][j].counter >= CGFloat(grassRows[i].count) {
					grassRows[i][j].counter = 0
					grassRows[i][j].spawn = arc4random_uniform(10) >= spawnChance
				}

				var range = getDistance(grassRows[i][j].spawnLocation, point2: rowLocations[i][1])

				if grassRows[i][j].spawn {
					grassRows[i][j].position = CGPoint(x: grassRows[i][j].spawnLocation.x - (grassRows[i][j].counter * (range.x / 5)), y: grassRows[i][j].spawnLocation.y - (grassRows[i][j].counter * (range.y / 5)))
				} else {
					grassRows[i][j].position = CGPoint(x: -grassRows[i][j].frame.width, y: -grassRows[i][j].frame.height)
				}

				grassRows[i][j].setScale(0.3 + (grassRows[i][j].counter * 0.2))
				grassRows[i][j].counter += 0.05
			}
		}
		/* Grass */

		/* Enemies */
		for var i = 0; i < enemies.count; ++i {
			if enemies[i].counter >= CGFloat(enemies.count + 1) {
				var tempLoc = CGPoint(x: ball.position.x, y: CGFloat((arc4random_uniform(UInt32(self.frame.height / 2)))) + (self.frame.height / 2))
				enemies[i].spawnLocation = tempLoc
				enemies[i].counter = 0
				enemies[i].texture = SKTexture(imageNamed: "Character_L")

				score++;
				scoreBoard.text = "Score: " + String(score)

				if score % 20 == 0 {
					enemies.append(createSpriteAt(sprite: "Character_L", location: CGPoint()))
					enemies.last!.spawnLocation = tempLoc
					enemies.last!.counter = CGFloat(enemies.count)
					self.addChild(enemies.last!)
				}
			}

			var range = getDistance(CGPoint(x: -enemies[i].frame.width, y: enemies[i].spawnLocation.y), point2: CGPoint(x: enemies[i].spawnLocation.x, y: ball.position.y))

			enemies[i].position = CGPoint(x: -enemies[i].frame.width - (enemies[i].counter * (range.x)), y: enemies[i].spawnLocation.y - (enemies[i].counter * (range.y)))
			enemies[i].setScale(0.5 + (enemies[i].counter * 0.1))
			enemies[i].counter += 0.02

			if enemies[i].position.x + (enemies[i].frame.width / 2) <= ball.position.x + (ball.frame.width / 2) && enemies[i].position.x + (enemies[i].frame.width / 2) >= ball.position.x - (ball.frame.width / 2) {
				if enemies[i].position.y - (enemies[i].frame.height / 2) <= ball.position.y + (ball.frame.height / 2) && enemies[i].position.y - (enemies[i].frame.height / 2) >= ball.position.y - (ball.frame.height / 2) {
					goToGameOverScene()
				}
			}
		}
		/* Enemies */

		moveBall()
	}

	func moveBall() {
		if motionManager.gyroAvailable {
			if !motionManager.gyroActive {
				motionManager.startGyroUpdatesToQueue(queue, withHandler: {
					(data: CMGyroData!, error: NSError!) in
					if data.rotationRate.x < -1 || data.rotationRate.x >= 1 || data.rotationRate.y < -1 || data.rotationRate.y >= 1 {
						if self.ball.position.x <= 0 {
							self.ball.position.x++
						} else if self.ball.position.x >= self.frame.width {
							self.ball.position.x--
						} else {
							self.ball.position.x += CGFloat(self.radians(fromDegrees: data.rotationRate.x)) * 0.1
						}
					}
				})
			} else {
				//println("Gyro si actieve urredy")
			}
		} else {
			//println("Gyro si niet availablu")
		}
	}

	func radians(fromDegrees degrees: Double) -> Double {
		return 180 * degrees / M_PI
	}

	func getDistance(point1: CGPoint, point2: CGPoint) -> CGPoint {
		return CGPoint(x: (point1.x - point2.x), y: (point1.y - point2.y))
	}

	func goToGameOverScene() {
		let gameOverScene: GameOverScene = GameOverScene(size: self.size) // create your new scene
		let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0) // create type of transition (you can check in documentation for more transtions)
		gameOverScene.scaleMode = SKSceneScaleMode.AspectFill
		gameOverScene.setScore(score: score)

		self.view!.presentScene(gameOverScene, transition: transition)
	}

	func goToHelpScene() {
		let helpScene: HelpScene = HelpScene(size: self.size)
		let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
		helpScene.scaleMode = SKSceneScaleMode.AspectFill

		self.view!.presentScene(helpScene, transition: transition)
	}

	func createSpriteAt(sprite name: String, location: CGPoint) -> CustomSprite {
		let sprite = CustomSprite(imageNamed: name)

		sprite.position = location

		return sprite
	}
}

class HelpScene: SKScene {
	let movementMessage = SKLabelNode(fontNamed: "Chalkduster")
	let goalMessageLine1 = SKLabelNode(fontNamed: "Chalkduster")
	let goalMessageLine2 = SKLabelNode(fontNamed: "Chalkduster")

	override func didMoveToView(view: SKView) {
		movementMessage.fontSize = 36
		movementMessage.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidX(self.frame))
		movementMessage.text = "Tilt or turn the device to move the ball."
		self.addChild(movementMessage)

		goalMessageLine1.fontSize = 28
		goalMessageLine1.position = CGPoint(x: CGRectGetMidX(self.frame), y: movementMessage.position.y - (movementMessage.frame.height * 2))
		goalMessageLine1.text = "Your goal is to get as close as possible to scoring,"
		self.addChild(goalMessageLine1)

		goalMessageLine2.fontSize = 28
		goalMessageLine2.position = CGPoint(x: CGRectGetMidX(self.frame), y: goalMessageLine1.position.y - goalMessageLine1.frame.height)
		goalMessageLine2.text = "while avoiding the opponents!"
		self.addChild(goalMessageLine2)
	}

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		goToGameScene()
	}

	func goToGameScene() {
		let gameScene: GameScene = GameScene(size: self.size) // create your new scene
		let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.AspectFill
		self.view!.presentScene(gameScene, transition: transition)
	}
}

class GameOverScene: SKScene {
	let gameOverMessage = SKLabelNode(fontNamed: "Chalkduster")
	let scoreMessage = SKLabelNode(fontNamed: "Chalkduster")
	let tryAgainMessage = SKLabelNode(fontNamed: "Chalkduster")

	var finalScore: Int = 0

	override func didMoveToView(view: SKView) {
		gameOverMessage.fontSize = 48
		gameOverMessage.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
		gameOverMessage.text = "Game Over!"
		self.addChild(gameOverMessage)

		scoreMessage.fontSize = 28
		scoreMessage.position = CGPoint(x: CGRectGetMidX(self.frame), y: gameOverMessage.position.y - gameOverMessage.frame.height)
		scoreMessage.text = "Your score was: " + String(finalScore)
		self.addChild(scoreMessage)

		tryAgainMessage.fontSize = 24
		tryAgainMessage.position = CGPoint(x: CGRectGetMidX(self.frame), y: scoreMessage.position.y - scoreMessage.frame.height)
		tryAgainMessage.text = "Tap to try again"
		self.addChild(tryAgainMessage)
	}

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		goToGameScene()
	}

	func setScore(score value: Int) {
		finalScore = value
	}

	func goToGameScene() {
		let gameScene: GameScene = GameScene(size: self.size) // create your new scene
		let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.AspectFill
		self.view!.presentScene(gameScene, transition: transition)
	}
}