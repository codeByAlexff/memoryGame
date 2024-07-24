import SwiftUI

struct MainView: View {
    @State private var bounce = false
    @State private var animationStates: [Bool] = Array(repeating: false, count: "memoriah".count)


    var body: some View {
        NavigationView {
            VStack {
                                Image(.brain2)
                                    .resizable()
                                    .frame(width: 200, height: 200)
                                    .padding(.top, 30)
                                    .phaseAnimator([false, true]) { brain2, chromaRotate in brain2
                                        .scaleEffect(1, anchor: chromaRotate ? .bottom : .topTrailing)
                                        .hueRotation(.degrees(chromaRotate ? 400 : 0))
                                        .offset(y: bounce ? -30 : 0) // Adding the bounce offset here
                                    }
                                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: bounce) // Bouncing animation
                                    .onAppear {
                                        bounce = true
                                    }
                HStack(spacing: 0){
                    
                    ForEach(Array("memoriah".enumerated()), id: \.offset) { index, character in Text(String(character))
                            .offset(y: animationStates[index] ? -10 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.2), value: animationStates[index])
                    }.font(.custom("Futura", size: 50))
                        .padding(.bottom, 20)
                        .dynamicTypeSize(.xxxLarge)
                    }.onAppear {
                    Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
                        startBouncingAnimation()
                    }
                    startBouncingAnimation()
                }

            

                                Text("Pick a mode")
                                    .font(.headline)
                                    .dynamicTypeSize(.xxxLarge)
                                    .padding(.bottom, 10)

                                Text("Flip Card")
                                    .font(.subheadline)
                                GeometryReader { geometry in
                                    HStack {
                                        NavigationLink(destination: GameBoardView(mode: .practice).onAppear {
                                            if !SoundManager.shared.isBackgroundMusicPlaying() {
                                                SoundManager.shared.playBackgroundMusic(named: "bg2")
                                            }
                                        }) {
                                            Text("👶 Practice Mode")
                                                .font(.title3)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(GrowingButton())
                                        
                                        NavigationLink(destination: GameBoardView(mode: .timed).onAppear {
                                            if !SoundManager.shared.isBackgroundMusicPlaying() {
                                                SoundManager.shared.playBackgroundMusic(named: "bg2")
                                            }
                                        }) {
                                            Text("⏰ Timed Mode")
                                                .font(.title3)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(GrowingButton())
                                    }
                                    .frame(width: geometry.size.width)
                                }

                                Text("Flashcards")
                                    .font(.subheadline)
                                GeometryReader { geometry in
                                    HStack {
                                        NavigationLink(destination: FlashcardCreationView()) {
                                            Text("🖊️ Create Card")
                                                .font(.title3)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(GrowingButton())

                                        NavigationLink(destination: FlashcardView().onAppear {
                                            if !SoundManager.shared.isBackgroundMusicPlaying() {
                                                SoundManager.shared.playBackgroundMusic(named: "bg2")
                                            }
                                        }) {
                                            Text("📓 Memorize")
                                                .font(.title3)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(GrowingButton())
                                    }
                                    .frame(width: geometry.size.width)
                                }

                                NavigationLink(destination: FlashcardQuizView().onAppear {
                                    if !SoundManager.shared.isBackgroundMusicPlaying() {
                                        SoundManager.shared.playBackgroundMusic(named: "bg2")
                                    }
                                }) {
                                    Text("🤓 Quiz Mode")
                                        .font(.title3)
                                        .frame(maxWidth: 150)
                                }
                                .buttonStyle(GrowingButton())
            
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showLeaderboard.toggle()
                                    }) {
                                        Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                                    }
                                }

                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        showProfile.toggle()
                                    }) {
                                        Image("custom.person.circle.fill.badge.gearshape.fill")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                            .sheet(isPresented: $showLeaderboard) {
                                LeaderboardView()
                            }
                            .sheet(isPresented: $showProfile) {
                                UserProfileView()
                            }
                        }
                        .onAppear {
                            if !SoundManager.shared.isBackgroundMusicPlaying() {
                                SoundManager.shared.playBackgroundMusic(named: "bg")
                            }
                        }
                    }

                    // MARK: Private

                    @State private var showLeaderboard = false
                    @State private var showProfile = false
    
    private func startBouncingAnimation() {
            for (index, _) in animationStates.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animationStates[index].toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Reset the state back after the animation
                        withAnimation(.easeInOut(duration: 0.5)) {
                            animationStates[index].toggle()
                        }
                    }
                }
            }
        }


                }

                #Preview {
                    MainView()
                        .modelContainer(previewContainer)
                }



