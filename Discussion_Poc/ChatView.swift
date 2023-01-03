//
//  ChatView.swift
//  Discussion_Poc
//
//  Created by Loïc MAZUC on 20/09/2022.
//

import SwiftUI
import Combine

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ScrollViewContent: View {
    var messages: CurrentValueSubject<[Message], Never>
    @State var _messages: [Message] = []
    
    var body: some View {
        VStack {
            ForEach(_messages) { message in
                ContentMessageView(message: message)
                    .id(message.id)
                    .onTapGesture {
                        print("🙆‍♂️", _messages.firstIndex(of: message))
                    }
            }
        }
        .onReceive(messages) {
            _messages = $0
        }
        .onAppear {
            _messages = messages.value
        }
    }
}

struct ChatView: View {
    @ObservedObject var viewModel = ChatViewModel()
    @State var newText = ""
    
    @State var loadedForTheFirstTime: Bool = true
    
    static let replyInputViewID: String = "replyInputViewID"
    static let scrollViewCoordinateSpaceName: String = "scrollView"
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.vertical) {
                    ScrollViewContent(messages: viewModel.messages)
                        .padding(16)
                        .background(GeometryReader { proxy in
                            let offset = proxy.frame(in: .named(Self.scrollViewCoordinateSpaceName)).minY
                            Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        })
                }
                .scrollDismissesKeyboard(.automatic)
                .onAppear {
                    viewModel.onAppear()
                    scrollToBottom(scrollView: scrollView)
                    loadedForTheFirstTime = false
                }
                .coordinateSpace(name: Self.scrollViewCoordinateSpaceName)
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    if !loadedForTheFirstTime {
                        loadMoreMessagesIfNeeded(offset: value, scrollView: scrollView)
                    }
                    print("🌸", value)
                }
                
                //
                //                VStack {
                //                    Divider()
                //                    HStack {
                //                        TextField("Message...", text: $newText)
                //                        Button("Envoyer") {
                //                            viewModel.addMessage(with: newText)
                //                            withAnimation { scrollToBottom(scrollView: scrollView) }
                //                        }
                //                        .padding(16)
                //                        .background(Color.blue)
                //                        .foregroundColor(.white)
                //                        .clipped()
                //                        .cornerRadius(8)
                //                    }
                //                    .padding(8)
                //                }
            .navigationTitle("ChatView")
        }
    }
    
    func scrollToBottom(scrollView: ScrollViewProxy) {
        scrollView.scrollTo(viewModel._messages.last?.id, anchor: .bottom)
    }
    
    func loadMoreMessagesIfNeeded(offset: CGFloat, scrollView: ScrollViewProxy) {
        if offset > -50 {
            if !viewModel.flag {
                viewModel.flag = false
                let lastMessageBeforeAdding = viewModel._messages.first
                viewModel.loadMoreMessages()
                RunLoop.main.perform {
                    scrollView.scrollTo(lastMessageBeforeAdding?.id, anchor: .top)

                }
            }
        }
    }
}

// MARK: - ViewModel

class ChatViewModel: ObservableObject {
    var messages: CurrentValueSubject<[Message], Never> = .init([])
    var _messages: [Message] {
        didSet {
            messages.send(_messages)
        }
    }
    var flag: Bool = false
    
    init() {
        _messages = []
    }
    
    func onAppear() {
        _messages = messageListOne
            .sorted { $0.date < $1.date }
            .suffix(10)
    }
    
//    func addMessage(with text: String) {
//        messages.append(Message(text: text, fromMe: Bool.random(), attachements: 0, date: Date()))
//    }
    
    func loadMoreMessages() {
        _messages.insert(contentsOf: createMessages(), at: 0)
    }
    
    func createMessages() -> [Message] {
        var messages: [Message] = []
        for _ in 0..<10 {
            messages.append(.init(text: randomString(), fromMe: Bool.random(), attachements: Int.random(in: 0...3), date: Date.randomDate()))
        }
        return messages
    }
}

// MARK: - Model

struct Message: Hashable, Codable, Identifiable {
    var id: String = UUID().uuidString
    var text: String
    var fromMe: Bool
    var attachements: Int
    var date: Date
}


func randomString() -> String {
    let from = Int.random(in: 20...50)
    let to = Int.random(in: 80...150)
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((from..<to).map{ _ in letters.randomElement()! })
}

var messageListOne: [Message] = [
    
    Message.init(text: "Aute aliqua esse culpa nisi officia incididunt nostrud commodo eiusmod mollit. Aliquip nisi consequat minim proident mollit. Est cupidatat sit do sunt quis cillum consectetur dolore.",
                 fromMe: true,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Exercitation elit Lorem qui id reprehenderit fugiat Lorem. Sunt esse et laborum Lorem aliquip sunt tempor tempor fugiat minim commodo. Do ullamco qui sit amet enim ullamco aute voluptate. Consectetur in exercitation ex occaecat magna esse culpa. In sit veniam aute et pariatur enim aliquip excepteur aute. Deserunt exercitation magna velit enim adipisicing cupidatat quis ad deserunt culpa. Qui ad nulla reprehenderit sit in aliquip incididunt magna reprehenderit ea veniam nostrud ad.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Consectetur sunt eu duis exercitation excepteur nisi dolor aliqua ut ad adipisicing proident ut nulla. Consectetur Lorem anim eu minim tempor proident adipisicing deserunt laboris ipsum dolore veniam enim sint. Mollit tempor et fugiat est duis. Aliquip ipsum sunt dolor ipsum occaecat. Consectetur enim ullamco ea irure veniam esse ipsum laborum. Enim proident officia cillum enim proident do consectetur do nisi est occaecat.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Dolore commodo sit incididunt quis ut esse eu consectetur duis incididunt consequat incididunt duis. Commodo aute commodo cillum eiusmod voluptate esse Lorem ut magna minim. Veniam quis laborum do nostrud reprehenderit do Lorem ipsum occaecat labore culpa. Dolor laborum fugiat anim mollit. Cillum ipsum ea id consequat deserunt sunt labore officia esse do aliquip. Exercitation minim magna tempor in amet velit non enim. Eu officia magna eu excepteur enim adipisicing est deserunt aute enim aliqua.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Velit non fugiat est consequat esse aute adipisicing in commodo dolor mollit do nostrud. Eu minim amet incididunt cillum. Duis veniam tempor aute commodo aute qui dolor esse labore proident. Ad anim consectetur sit culpa sint laboris qui dolore pariatur reprehenderit. Pariatur proident dolore excepteur incididunt eiusmod aliqua pariatur ex exercitation aliquip. Nulla dolor id ea laborum ad et quis nostrud fugiat voluptate anim. Aute et esse commodo elit.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Magna laboris enim adipisicing dolor qui qui est ex ut do enim. Consectetur aliqua tempor nostrud qui et est adipisicing tempor. Magna mollit non minim amet dolor ut commodo. Lorem enim eiusmod labore eu pariatur qui. Ex dolore id incididunt nisi velit velit ex ut incididunt laborum aliqua. Amet ipsum qui quis ullamco.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Fugiat pariatur enim laborum sunt ex cillum Lorem est nisi incididunt cillum. Deserunt sit dolore fugiat non enim incididunt incididunt voluptate enim deserunt velit sit anim. Commodo veniam reprehenderit quis in officia sit in irure magna nostrud laboris nulla mollit. Esse eiusmod veniam anim labore do proident quis. Exercitation exercitation voluptate dolor sit ex.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Culpa consectetur veniam minim anim. Dolor culpa culpa in ea occaecat veniam ex deserunt est consequat quis in sunt. Amet velit magna deserunt ex. Ea nisi reprehenderit anim in culpa aliquip. Occaecat minim officia eiusmod est do esse. Dolore amet enim sit sint duis sint tempor est est enim velit. Cillum consectetur commodo adipisicing dolor culpa occaecat enim proident sunt occaecat enim.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Laborum commodo magna est quis. Proident ex nisi nostrud amet esse sit in in nulla elit anim. Enim ex cupidatat incididunt irure qui ipsum duis sint. Qui elit do id sint pariatur laboris incididunt et ex ea voluptate sit aliqua nisi.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Officia consequat excepteur Lorem magna deserunt non. Reprehenderit reprehenderit culpa id in sint Lorem ut cupidatat id. Tempor dolor qui dolor dolore cillum dolor aliquip fugiat minim fugiat fugiat minim. Culpa ea cupidatat ad reprehenderit dolore anim. Anim pariatur nostrud est incididunt pariatur et ut ea irure dolor. Voluptate proident consequat sunt id aliquip Lorem in laboris labore nulla nisi ea. Exercitation deserunt ex dolore officia cillum aliquip cupidatat enim.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Sit do id deserunt aliquip minim non ullamco et incididunt. Nostrud sunt dolore cupidatat veniam ad veniam voluptate sit aliqua. Adipisicing non qui et et enim. Velit veniam reprehenderit exercitation dolor amet consectetur voluptate consectetur adipisicing culpa ad amet ullamco laborum. Nulla est mollit reprehenderit esse. Deserunt aliquip mollit laborum pariatur magna ea eu culpa aliquip et exercitation. Veniam pariatur ut irure eiusmod enim culpa est.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Excepteur tempor qui ipsum cillum. Laborum amet enim exercitation incididunt minim culpa minim sunt aliquip in nostrud non. Aliqua ea Lorem laboris consequat aute pariatur ullamco reprehenderit laboris anim. Aliquip nostrud aliquip exercitation nostrud nostrud occaecat.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Laboris occaecat sint qui culpa reprehenderit laboris ad exercitation occaecat dolor commodo. Nostrud cillum ipsum fugiat deserunt sunt mollit consequat elit deserunt consectetur anim anim aliquip quis. Sit eiusmod ad dolor proident. Labore sint non ut anim duis aliquip consequat consequat laborum tempor sunt nulla. Esse nulla irure nisi sunt proident anim qui irure ut aute tempor in. Laborum aliqua Lorem et nisi laboris non. Sunt non aliquip incididunt qui occaecat sint cillum fugiat commodo reprehenderit id aliquip magna non.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Minim non duis in non quis ad culpa non excepteur commodo. Esse ipsum elit tempor dolor nostrud cupidatat anim fugiat officia. Occaecat eu ullamco dolor esse aute enim anim sit excepteur ad sunt nulla ut excepteur. Laborum ad occaecat excepteur do. Aliquip deserunt elit consequat amet sunt sunt elit voluptate aliquip ullamco anim.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Esse aliqua eu mollit proident eu exercitation velit aute voluptate in reprehenderit. Do non sint sit ad culpa consequat do eiusmod reprehenderit irure cupidatat nulla. Sunt adipisicing nulla proident pariatur occaecat ad. Nulla consequat in ipsum consectetur anim adipisicing reprehenderit consequat est. Amet reprehenderit occaecat aliqua consectetur veniam irure dolore commodo minim ex ipsum sit exercitation duis. Culpa ut incididunt est fugiat anim.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Consequat esse nostrud cillum duis ad ea adipisicing pariatur reprehenderit laborum nisi ad sunt. Fugiat consectetur culpa proident ullamco aliquip voluptate labore duis consectetur do. Proident eu non ipsum commodo laboris qui qui exercitation consequat adipisicing pariatur. Fugiat cupidatat nostrud occaecat culpa aute.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Irure magna amet mollit ut eiusmod cillum laboris. Anim nostrud exercitation veniam eu culpa do eiusmod ullamco reprehenderit nisi. Laborum excepteur veniam labore et eiusmod ullamco tempor proident. Anim enim sit sint elit voluptate qui in pariatur reprehenderit commodo commodo culpa non. Eu ea proident ullamco ipsum.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Ad irure irure voluptate nisi consequat enim pariatur reprehenderit ex magna ut cillum. Eiusmod do dolor ea aliqua cupidatat Lorem sint in aute adipisicing sint in officia qui. Proident eu ad eu magna Lorem id. Amet elit sunt magna labore et officia sunt proident culpa ut. Incididunt non fugiat tempor ad et qui reprehenderit ex id ipsum nostrud. Esse adipisicing est dolor nostrud dolore elit aliquip.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Incididunt irure sint mollit reprehenderit cupidatat minim occaecat officia do non eiusmod. Aliquip do id consectetur irure et cillum. Sint sit pariatur qui esse ex labore in eu nulla et excepteur laboris deserunt. Exercitation pariatur consectetur culpa sit consequat exercitation elit dolor. Ut incididunt pariatur eiusmod elit dolor quis enim enim amet laboris exercitation consectetur magna nulla. Proident non consectetur officia Lorem velit.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Exercitation dolore irure dolor ipsum ex cillum Lorem est id eiusmod consectetur tempor. Excepteur quis nostrud eu aute sit adipisicing sunt excepteur adipisicing aliqua sint cupidatat commodo anim. Labore incididunt pariatur dolor in voluptate dolore non enim eu pariatur in laborum. Ex aliquip proident velit exercitation voluptate labore labore aliquip magna non. Minim culpa reprehenderit veniam mollit irure. Sunt nulla quis duis est ut ullamco ad exercitation consectetur.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Sunt ex occaecat quis proident tempor laborum aliqua ut dolore. Lorem laboris nostrud veniam dolore Lorem veniam. Cillum amet nulla enim nisi exercitation pariatur est deserunt esse incididunt ad id. Id in occaecat voluptate ut consequat veniam aliqua mollit ex velit. Nostrud id sint mollit tempor magna commodo pariatur. Lorem nulla deserunt nostrud magna eiusmod cillum magna.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Cillum proident do ea fugiat fugiat qui mollit dolor pariatur reprehenderit eu eu enim. Incididunt ex deserunt elit irure ullamco amet nulla quis. Veniam qui magna et quis consectetur minim est nisi eiusmod eu. Voluptate id aute aute incididunt tempor nisi id fugiat occaecat tempor duis veniam ex. Cillum mollit quis aliquip labore velit ut ipsum voluptate laboris.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Cillum dolor et exercitation eu duis. Qui culpa adipisicing veniam irure minim ex magna anim. Et minim occaecat commodo mollit quis veniam ullamco qui. Minim laborum laborum nostrud nulla.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Sit pariatur ex deserunt eu veniam nostrud ut do minim exercitation sint Lorem ad tempor. Nulla voluptate cupidatat occaecat Lorem sint ipsum id ipsum officia consectetur sit. Pariatur dolor fugiat commodo commodo pariatur aliquip fugiat sit sit. Voluptate exercitation id fugiat nisi ullamco nisi sunt et sunt deserunt laborum.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Do dolore nostrud irure laborum culpa duis proident nulla labore. Nostrud commodo ut voluptate incididunt Lorem mollit elit enim officia id labore ea mollit eiusmod. Proident laborum nostrud occaecat laboris nostrud qui ex excepteur id. Elit ipsum duis esse exercitation eu ipsum enim excepteur exercitation aliquip nulla. Commodo ad consequat mollit ipsum et aliquip occaecat cillum tempor excepteur dolore ex.",
                 fromMe: true,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Dolor magna officia reprehenderit labore reprehenderit ex adipisicing aliquip consectetur. Nulla sint consequat excepteur dolore tempor anim proident Lorem excepteur nisi ea veniam ex in. Dolor deserunt consequat qui aute fugiat.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Culpa ex aute est magna pariatur pariatur exercitation aliqua ea. Velit et amet incididunt non aute anim nisi. Consectetur voluptate laboris veniam mollit exercitation pariatur anim et officia. Ea eu ipsum amet laboris labore. Pariatur et irure est incididunt. Dolore officia id et ullamco laborum fugiat. Laboris ipsum mollit occaecat ipsum nisi.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Deserunt nulla in magna incididunt. Laborum ea quis consequat veniam eu occaecat ipsum ipsum tempor aute excepteur ea reprehenderit. Anim amet aliquip et ullamco mollit eu fugiat ex ea nulla.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Pariatur et nulla esse adipisicing velit proident fugiat eu est cupidatat sunt proident. Aute enim voluptate adipisicing ipsum irure labore. Anim duis excepteur exercitation ullamco culpa esse.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "In pariatur aute nisi nisi. Commodo ex aliqua laboris enim cupidatat est elit elit laboris. Aute velit ipsum irure non. Occaecat do eiusmod sit incididunt culpa ex ullamco esse labore et sit ad Lorem occaecat.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Id mollit incididunt aliqua reprehenderit. Ullamco consequat exercitation dolor aliqua duis ex cupidatat aute consequat enim consectetur tempor exercitation eu. Ex officia labore est id ex aliqua laborum voluptate fugiat cillum consectetur ut esse. Enim ea aliquip magna elit velit esse dolore.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Id ut aliquip eu est culpa ipsum irure sint occaecat incididunt. Dolor ipsum laboris cillum exercitation. Exercitation ullamco adipisicing elit elit. Occaecat Lorem ad laborum culpa duis Lorem.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Pariatur ea ipsum incididunt sint pariatur velit proident. Dolor nulla fugiat fugiat in commodo. Reprehenderit nulla dolor qui nulla amet ea sit elit duis. Laboris nostrud veniam voluptate eu ullamco ex veniam occaecat excepteur labore.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Est officia occaecat quis aliquip id mollit duis magna non. Ut do minim sit consectetur proident occaecat irure consectetur adipisicing velit. Nisi irure exercitation veniam proident.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Anim ut in adipisicing velit qui voluptate tempor pariatur mollit elit enim eu elit Lorem. Lorem mollit anim ex cillum fugiat labore excepteur sit consequat quis ullamco. Pariatur amet irure quis excepteur eiusmod ullamco pariatur. Consequat quis magna consequat nostrud quis excepteur aliqua labore sint labore laboris dolor ad in. Do consequat do ea duis officia minim nisi velit non culpa irure duis dolor.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Tempor sint cupidatat eiusmod pariatur nisi magna officia. Veniam eu cupidatat id veniam minim ad eiusmod et ex consequat quis commodo. Labore et anim non proident. Aliquip id dolore reprehenderit reprehenderit voluptate. Quis duis duis magna in mollit aliquip fugiat laborum irure pariatur.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Amet et mollit et consequat deserunt eiusmod qui proident ad proident. Quis adipisicing non deserunt esse occaecat do ipsum nostrud Lorem duis tempor nostrud eu. Laborum dolor nulla sint qui elit in laboris duis et pariatur ea. Ipsum sunt nulla irure eu ea sit do est. Nostrud ullamco veniam est est reprehenderit non incididunt aliqua reprehenderit eu sit.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Incididunt reprehenderit ad irure nostrud esse dolore fugiat labore nostrud excepteur cupidatat cillum enim. Mollit dolor consequat excepteur incididunt non do nisi quis qui aliquip. Ipsum aliquip ea duis reprehenderit laboris ullamco laborum Lorem officia ipsum ea ut. Ullamco nulla tempor culpa est proident.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Qui officia sit cillum do ea consequat in. Sit tempor eu ut voluptate in labore aliqua. Laboris et irure minim et amet in occaecat ut. Aute voluptate dolor id laboris. Esse occaecat tempor officia nostrud dolor velit in. Lorem magna cillum veniam cillum magna cupidatat aliqua anim consectetur tempor Lorem do ipsum duis.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Ea velit aliquip minim culpa incididunt anim magna non adipisicing occaecat fugiat incididunt laborum. Reprehenderit excepteur in non eu eu duis sit adipisicing consequat. Ut ullamco Lorem Lorem mollit duis veniam fugiat occaecat. Pariatur irure tempor laborum labore voluptate aliqua. Mollit officia consectetur sint enim pariatur ipsum aute ullamco Lorem commodo laboris. Veniam anim veniam commodo Lorem pariatur ullamco.",
                 fromMe: true,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Quis incididunt minim deserunt ad cupidatat duis et veniam adipisicing qui Lorem ea. Ipsum consequat irure elit nulla sint consectetur ad ullamco irure veniam quis adipisicing dolore ullamco. Laborum non cillum ipsum cillum culpa cupidatat. Eu velit irure Lorem adipisicing id pariatur non occaecat elit ea do. Irure aute exercitation elit ipsum incididunt culpa veniam commodo aliqua elit laboris do ut. Non eiusmod pariatur aute eiusmod.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Et Lorem ex ut cupidatat. Minim eu incididunt aute pariatur. Exercitation elit ea reprehenderit cupidatat proident velit pariatur aute consequat ea proident Lorem excepteur. Ad magna consectetur in minim ea nostrud deserunt sit occaecat veniam non consequat tempor esse.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Minim nostrud consequat proident ut cillum cupidatat id culpa eiusmod quis. Eiusmod reprehenderit amet aute ex incididunt cillum commodo. In mollit mollit amet irure veniam eu culpa ad reprehenderit enim. Proident aliquip sint laboris est nisi ipsum non. Anim consectetur Lorem excepteur dolor ex mollit culpa in eu adipisicing mollit sunt et. Labore do consectetur proident excepteur aute eu do mollit consequat ipsum nostrud incididunt enim aliqua. Deserunt ea et veniam consectetur aliquip elit dolore.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Ex occaecat dolore eu quis. Est excepteur consectetur veniam excepteur laboris commodo amet deserunt sunt ex ad commodo incididunt. Commodo reprehenderit ipsum anim occaecat id duis sit sunt aliquip officia nulla. Consequat Lorem ad mollit ullamco adipisicing nulla reprehenderit voluptate incididunt minim. Dolore adipisicing enim et aliquip ullamco qui laborum anim tempor officia cillum.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Irure reprehenderit eiusmod ut irure duis esse aute est ut tempor sunt reprehenderit. Sint eu eu ullamco et esse in et est est aliquip qui aute culpa ipsum. Eiusmod tempor anim voluptate ullamco. Lorem aute dolor ipsum culpa in dolore aliqua. Nostrud proident et ea id non ex dolore ipsum laboris ad minim laboris sint.",
                 fromMe: true,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Do proident do tempor duis consequat minim et laborum eiusmod nulla Lorem consequat. Aliqua veniam ut pariatur ex officia deserunt veniam occaecat culpa fugiat duis veniam. Enim veniam enim do minim elit aute ad. Voluptate exercitation ullamco est officia consectetur consequat magna exercitation sit duis. Tempor ut Lorem occaecat consequat id do sit. Anim nulla aliquip mollit cillum labore labore nisi ipsum officia aliquip velit eiusmod. Deserunt excepteur laboris labore officia et aute Lorem.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Labore laboris labore officia laborum ut aliqua culpa consectetur nostrud qui tempor do duis magna. Qui dolor irure Lorem veniam esse proident amet sunt do quis sint officia. Velit irure ipsum do dolore pariatur esse et cillum pariatur in dolore culpa adipisicing. Et reprehenderit laboris ad deserunt. Minim deserunt veniam excepteur consequat incididunt magna non esse veniam ipsum minim.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Dolor fugiat eu sit irure labore anim do enim sint veniam proident nisi. Pariatur in consectetur cillum eu laboris. Non consectetur ad adipisicing ullamco. Irure deserunt ut est irure eu. Aliquip ullamco do ad exercitation do non consequat pariatur incididunt cupidatat. Nostrud sit fugiat occaecat amet tempor amet. Magna culpa deserunt dolore sunt cupidatat.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Ut consequat irure nisi elit reprehenderit id irure exercitation. Fugiat fugiat velit aliquip qui ipsum. Pariatur nisi elit qui cupidatat aliquip culpa labore non mollit ea non nisi deserunt ullamco. Ullamco sit ipsum id qui nisi cillum. Sint qui ex incididunt tempor fugiat veniam ipsum ut aliqua occaecat consequat occaecat reprehenderit consequat. Consequat ex do et nulla aliquip enim id Lorem cillum aliquip. Eiusmod aute non magna do ex velit voluptate sit elit.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Voluptate est pariatur esse consequat incididunt et exercitation pariatur et minim et eiusmod id. Deserunt commodo commodo enim occaecat aliqua voluptate cillum Lorem eu. Occaecat ipsum ut commodo pariatur occaecat deserunt consectetur ea officia ut commodo incididunt incididunt. Dolor amet consectetur consequat aute. Reprehenderit non sunt culpa elit sit esse veniam adipisicing mollit.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Labore labore ex culpa nulla. Incididunt ad labore in magna nisi nulla officia consectetur laborum. Ut esse nulla proident non. Quis cillum dolore qui consequat cupidatat excepteur esse voluptate ut irure incididunt.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Labore cillum elit fugiat ex cupidatat non veniam ea id incididunt nostrud. Eiusmod magna reprehenderit esse velit incididunt in commodo ex tempor excepteur fugiat sit cupidatat laboris. Aliqua minim velit nulla sit quis id eu sint magna aliqua veniam ad laboris voluptate.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Culpa irure pariatur non velit aute eiusmod tempor sunt nulla exercitation incididunt. Incididunt laborum consequat aliquip ex sint magna excepteur. Enim pariatur ullamco quis est dolore consequat nostrud mollit ex nulla commodo consectetur aliqua voluptate. Aute ad enim reprehenderit exercitation Lorem nulla. Aute culpa et et aliquip excepteur ea.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Qui eiusmod mollit ex cupidatat duis proident reprehenderit fugiat labore eiusmod proident. Eiusmod nisi reprehenderit excepteur excepteur labore esse in qui non aliquip laborum. Sit nisi labore consectetur cupidatat ipsum. Dolore id aliqua quis dolore.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Culpa officia ullamco duis occaecat laborum voluptate cillum. Cupidatat aliqua ad aliquip reprehenderit eiusmod sit proident sint irure proident dolore pariatur et amet. Cillum laborum ut irure quis laborum nulla. Ad reprehenderit magna exercitation non fugiat. Dolor enim ullamco sit ipsum dolor consequat veniam.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Magna dolor mollit sint adipisicing. Quis amet veniam cupidatat ex cupidatat tempor tempor. Voluptate et labore mollit et ad in dolore minim adipisicing laborum. Consectetur cupidatat anim deserunt in laboris in officia. Enim ullamco est est minim amet magna culpa cillum duis nostrud laborum eu. Tempor officia nulla ut cupidatat sit do anim adipisicing eu aute officia nulla adipisicing. Esse minim fugiat aliquip amet culpa aliqua est.",
                 fromMe: true,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Aliquip mollit duis culpa in ut est aliquip consectetur minim voluptate consectetur ea. Culpa tempor proident enim amet officia sunt culpa aute incididunt in. Ad laboris nostrud nisi commodo fugiat magna laborum ut deserunt consectetur ullamco.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Est et excepteur ea fugiat est occaecat quis sit deserunt. Cillum anim magna Lorem ullamco amet eu ut et eiusmod consequat do. Consequat exercitation deserunt laborum non. Non quis proident excepteur excepteur reprehenderit voluptate mollit adipisicing.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Quis id in elit eu deserunt est qui. Culpa amet laborum ex incididunt aliquip cupidatat nulla exercitation occaecat amet deserunt est incididunt. Culpa id enim laborum nisi labore mollit aliqua cupidatat. Non consequat do veniam consequat reprehenderit et minim mollit sit labore officia aliqua. Velit culpa in ullamco non irure.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Cupidatat exercitation enim ad eiusmod duis laborum non incididunt occaecat. Tempor ex aliquip eu exercitation eiusmod ea voluptate laboris labore. Sint ipsum eiusmod culpa irure consectetur eiusmod. Elit consequat occaecat occaecat do dolor ea dolore ullamco nostrud laborum ad.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Incididunt consequat ad cupidatat qui sit incididunt minim esse enim do. Lorem non dolore qui adipisicing irure culpa qui laborum adipisicing elit. Consequat ullamco commodo fugiat ex mollit consectetur. Dolore eu ad adipisicing pariatur officia ex nisi id sit. Lorem aute nulla sint duis nostrud excepteur sint irure incididunt sit enim adipisicing. Aliquip excepteur excepteur laborum incididunt quis aliquip.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Laborum occaecat exercitation laborum nostrud nulla elit aute ea officia ad. Id dolore voluptate consequat reprehenderit Lorem aliquip sunt elit esse in deserunt non mollit. Dolor ut in quis cupidatat velit reprehenderit est. Sunt et culpa sint eiusmod mollit sint. Officia dolore commodo occaecat ut ex excepteur consectetur. Minim mollit anim anim exercitation in ipsum cupidatat et et excepteur et proident.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Aliquip sit ad sint exercitation ut. Officia amet qui magna excepteur occaecat nulla laboris. Sint dolor eu magna irure nisi adipisicing pariatur ullamco.",
                 fromMe: true,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Incididunt quis occaecat velit anim do magna adipisicing ullamco excepteur. Mollit adipisicing veniam exercitation occaecat dolor deserunt sint consequat Lorem. Mollit proident velit anim exercitation laborum officia irure mollit consequat nisi et culpa. Ex nostrud laboris aliqua exercitation.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Sint minim cillum mollit ea ad irure. Et ullamco minim est esse eiusmod veniam. Et reprehenderit ut ullamco anim amet deserunt reprehenderit aliqua.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Amet labore ipsum adipisicing adipisicing esse consequat exercitation. Sit officia velit quis nulla eu dolore cupidatat occaecat amet cupidatat. Reprehenderit dolor aliqua veniam ipsum aute in deserunt qui. Irure do veniam cupidatat incididunt laborum excepteur aliqua anim est laboris commodo. Ut id ea do officia tempor amet commodo proident veniam do. Ut non adipisicing ex velit laborum. Proident minim ex adipisicing sit.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Magna labore pariatur nisi dolore. Deserunt non sint cillum consectetur nisi irure adipisicing nisi irure adipisicing do Lorem. Occaecat id laborum cupidatat proident ullamco consequat. Consectetur sit voluptate id voluptate Lorem consequat voluptate sint. Cillum excepteur ad nulla et. Excepteur tempor ut sit ullamco excepteur commodo ipsum aute commodo mollit nisi sint. Qui ex et aliqua ullamco proident sit veniam.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Velit id velit velit laborum ea. Laboris mollit proident ut sunt deserunt amet ipsum. Fugiat officia adipisicing sunt eiusmod cillum et aute minim amet non. Nostrud dolore sint aliqua amet non minim labore excepteur enim occaecat. Irure elit excepteur reprehenderit aliquip laborum adipisicing ullamco fugiat id.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Quis anim exercitation do aliquip. Irure eu incididunt officia culpa consequat proident magna labore ad cupidatat. Fugiat nulla labore elit id culpa magna eiusmod voluptate mollit magna velit nulla cillum ex.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Commodo incididunt amet quis cillum nostrud exercitation anim commodo officia et tempor. Non consectetur ea aliqua exercitation nulla excepteur. Occaecat dolore anim duis eu elit velit. Esse incididunt cillum pariatur et commodo fugiat deserunt voluptate dolor cupidatat duis excepteur aliquip elit. Velit elit laboris dolor fugiat laboris elit eiusmod velit. Lorem deserunt proident ut cillum minim nostrud nisi cupidatat officia velit non nisi reprehenderit est. Ullamco exercitation ex in anim.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Sint exercitation officia id exercitation reprehenderit laborum. Minim sunt magna enim exercitation. Magna aute consequat ullamco officia Lorem culpa amet nostrud duis laboris reprehenderit. Magna proident nisi adipisicing anim adipisicing ad et. Nisi laborum non sit aliqua exercitation labore non deserunt sunt. Dolore ex exercitation cillum id adipisicing adipisicing nulla nulla adipisicing adipisicing Lorem sit quis.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Ex ipsum consequat in dolor minim reprehenderit. Nostrud non aliqua in culpa sunt do excepteur fugiat aute mollit. Commodo amet do amet non veniam ullamco laborum commodo veniam. Sunt aliqua commodo do consequat ullamco incididunt duis. Voluptate culpa aliquip pariatur in deserunt incididunt cupidatat dolor. Amet cillum exercitation in magna in deserunt labore adipisicing laborum non nulla anim incididunt.",
                 fromMe: true,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Cillum occaecat officia esse elit do in sit. Non minim culpa minim irure quis sint enim voluptate proident dolore. Lorem ullamco tempor cillum duis ut nisi cupidatat consequat quis. Et nisi eiusmod aliquip cillum proident ea sunt nisi fugiat sint et.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Aliquip elit ullamco duis sunt est consequat in reprehenderit. Amet sint nisi Lorem occaecat aliquip ullamco consectetur eu voluptate. Adipisicing anim sit amet mollit deserunt in amet cillum laboris culpa officia ea nisi. Minim aliquip esse ex minim. Aliquip nisi ea adipisicing sunt nulla. Aliqua esse do fugiat ut mollit commodo fugiat culpa quis. Amet deserunt officia proident sunt quis.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Non aliquip tempor velit consectetur exercitation excepteur dolore nulla magna consequat et eiusmod pariatur. Pariatur esse aliqua voluptate aliquip. Voluptate commodo do fugiat proident. Eiusmod ad reprehenderit qui dolore adipisicing id adipisicing aute nostrud ullamco sint nulla qui proident. Est aute reprehenderit quis nisi officia consectetur commodo eu ea amet consequat.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "In reprehenderit culpa fugiat amet fugiat commodo commodo ea reprehenderit aliqua. Ea non velit officia incididunt eiusmod ipsum veniam consectetur non elit ex reprehenderit commodo ad. Cupidatat officia occaecat pariatur dolore ullamco do dolore velit proident. Et irure aliquip amet velit do veniam anim deserunt anim deserunt dolore est labore ea. Officia id non ex voluptate laboris voluptate aute id adipisicing duis. Occaecat commodo commodo magna cillum nisi occaecat commodo ad quis minim ea enim adipisicing. Nostrud nisi aliqua officia minim reprehenderit et et.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Dolore tempor aliquip mollit irure aute Lorem velit ea. Laborum fugiat proident excepteur veniam consequat veniam dolore consequat adipisicing. Id excepteur eu mollit nulla officia mollit laborum ex excepteur deserunt mollit sunt esse voluptate.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Eu laborum sint laboris id occaecat do ad. Consequat ipsum proident aute est ex exercitation duis adipisicing minim sint eiusmod do. Occaecat veniam velit pariatur non.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Qui minim aute commodo nisi do est irure. Cupidatat officia Lorem reprehenderit duis. Ex sit aliquip ipsum culpa quis aute cupidatat occaecat commodo. Sunt elit elit commodo aute esse ullamco tempor ad sint occaecat. In consequat esse qui pariatur culpa veniam proident sint. Enim reprehenderit proident pariatur anim consectetur dolore nulla minim et excepteur.",
                 fromMe: true,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Nostrud dolor occaecat eiusmod tempor adipisicing ea pariatur ut. Excepteur non proident adipisicing dolore. Sint esse deserunt id cupidatat ex qui reprehenderit consequat amet aute et eiusmod. Anim magna officia mollit aliqua proident nostrud aliquip mollit dolore tempor consequat cupidatat.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Aute velit minim labore sunt aute aliquip. Occaecat non est dolor nisi minim laborum elit aliquip mollit nisi eiusmod ullamco commodo. Duis est ad magna aliqua incididunt Lorem consequat esse aliquip nisi anim qui consequat. Ad adipisicing officia et nulla officia culpa. Ad ut proident nisi ad qui ut officia sunt ea labore culpa.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Ipsum voluptate laborum sunt officia eu occaecat laborum sit nisi. Cillum in nisi sit duis officia velit ut sint tempor ut nisi qui. Eu pariatur velit sunt ipsum minim voluptate labore.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Ex Lorem nulla mollit anim ullamco aute magna. Excepteur sint ea mollit consequat. Exercitation mollit incididunt ad ea consectetur ex dolor exercitation ex consectetur ad aute cillum.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Irure amet nostrud ea nisi Lorem veniam et nostrud. Irure pariatur ipsum voluptate est ipsum ad Lorem reprehenderit laborum qui. Velit non ipsum elit duis esse dolor. Mollit culpa dolore occaecat anim duis officia. Labore pariatur commodo dolore commodo aute. Dolor fugiat ea id fugiat voluptate proident non eiusmod deserunt. Nostrud reprehenderit cillum proident cupidatat.",
                 fromMe: false,
                 attachements: 3,
                 date: Date.randomDate()),
    
    Message.init(text: "Qui est proident labore nostrud non sit. Sit reprehenderit non nostrud anim dolore. Ullamco amet deserunt amet duis commodo nisi excepteur id dolor dolore consequat deserunt.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Proident et incididunt laboris eu sunt. Pariatur Lorem reprehenderit id aliqua consequat incididunt et cillum adipisicing. Exercitation excepteur enim mollit nostrud proident fugiat voluptate excepteur velit ut. Fugiat excepteur eiusmod velit quis. Voluptate aute laboris ut eu ea mollit est commodo sit eiusmod.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Enim ipsum dolor consectetur cillum quis esse officia sunt laborum exercitation. Cupidatat exercitation nulla Lorem exercitation sint ipsum ut sunt nulla dolore quis minim. In duis officia ea laborum cillum mollit nulla aliquip incididunt magna cupidatat. Deserunt velit aliqua aliquip deserunt exercitation nisi irure laboris laborum. Ut irure sunt aute enim dolore est nulla cillum aliquip. Et dolore amet magna ea eiusmod sunt nulla sint exercitation incididunt.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Magna proident proident sit Lorem nisi proident do officia labore. Elit Lorem dolor veniam ad nostrud. Pariatur et fugiat consequat ut. Aliqua cillum sunt proident sit sint est velit deserunt nisi. Non exercitation labore dolor anim enim. Eiusmod duis ad ad duis laborum sit enim aute aute excepteur reprehenderit do. Eiusmod minim consectetur quis nulla duis enim cillum ut consequat non Lorem labore.",
                 fromMe: false,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Veniam velit laborum voluptate ut id consectetur aute adipisicing. Culpa reprehenderit ex cillum ullamco voluptate qui amet veniam amet ipsum ea. Eiusmod voluptate voluptate proident commodo. Id dolor laborum ea excepteur ad elit nostrud et est quis laboris.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Quis aliqua sit nulla nisi fugiat et nostrud id irure pariatur id. Excepteur magna fugiat cillum incididunt ullamco laboris adipisicing cillum labore voluptate ipsum. Anim culpa laborum irure commodo voluptate eiusmod est cillum voluptate. Laboris eu non irure incididunt dolor anim cupidatat fugiat aliqua tempor dolore mollit. Mollit consectetur qui labore est sit minim sit esse eu consectetur officia aliqua eu in.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Incididunt duis ipsum sit ad fugiat elit et consequat velit aliquip. Cupidatat minim dolor ex culpa nulla officia mollit nostrud. Pariatur sit esse Lorem adipisicing voluptate sunt deserunt. Exercitation qui cillum occaecat culpa proident proident deserunt sunt dolore do. Voluptate cupidatat duis ullamco aliquip irure ad ipsum veniam sint pariatur aute. Pariatur ut ipsum qui pariatur ea velit voluptate in ad.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Est aliquip veniam anim ullamco nostrud duis minim irure. Incididunt dolore qui esse officia non labore exercitation velit aliqua nostrud commodo. Sint laboris elit reprehenderit Lorem excepteur adipisicing commodo pariatur do elit.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Adipisicing et Lorem fugiat excepteur et eu dolore esse velit. Anim elit ipsum aliqua magna qui anim culpa excepteur voluptate velit mollit deserunt fugiat tempor. Tempor dolor nostrud ut amet Lorem ad ullamco culpa elit. Dolor aute consequat eu sit sit.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Aute do voluptate velit tempor anim ea Lorem. Non nisi fugiat nulla amet laborum do et ex do. Duis ut aliquip reprehenderit nisi sint officia cupidatat Lorem est voluptate.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Nostrud dolore tempor non incididunt ex dolor dolore minim adipisicing. Magna aliqua ipsum eiusmod consequat. Pariatur tempor minim culpa est mollit cillum cillum eiusmod. Adipisicing do pariatur excepteur sit dolore exercitation excepteur dolor pariatur nulla. Quis non dolore consequat cupidatat ullamco do occaecat proident exercitation adipisicing consectetur minim adipisicing deserunt. Occaecat dolor aliquip in amet duis sint irure nulla sint velit dolore labore.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Duis amet cupidatat sunt excepteur quis excepteur magna velit id deserunt duis eu velit ipsum. Sit dolore tempor culpa veniam exercitation. Eu do cillum pariatur ullamco esse. Consequat eiusmod enim irure pariatur ea fugiat do consectetur ipsum fugiat. Enim qui velit pariatur reprehenderit pariatur pariatur nisi elit laborum Lorem ut. Do nisi enim nostrud ea fugiat enim sit duis aute laboris tempor est irure.",
                 fromMe: true,
                 attachements: 2,
                 date: Date.randomDate()),
    
    Message.init(text: "Ea esse labore non culpa qui labore magna amet nostrud dolor Lorem magna dolore. Nostrud duis reprehenderit quis deserunt id. Deserunt eu duis excepteur aliqua deserunt occaecat consectetur. Aliquip deserunt cillum irure irure aliquip ut est amet aliquip eu sit cupidatat ipsum exercitation. Ut dolor Lorem fugiat commodo fugiat sunt sunt consectetur ex exercitation do laborum labore ipsum. Mollit dolor proident nisi commodo labore Lorem pariatur enim.",
                 fromMe: false,
                 attachements: 0,
                 date: Date.randomDate()),
    
    Message.init(text: "Aute aute culpa ex mollit ullamco ex do nulla. Deserunt magna magna tempor aute enim nisi irure Lorem. Amet laboris ad ex amet. Non reprehenderit quis magna et tempor irure quis et anim. Adipisicing aute eiusmod esse nostrud ipsum qui in. Amet qui adipisicing incididunt commodo voluptate fugiat consectetur aliqua Lorem ipsum ullamco reprehenderit ea. Ullamco culpa excepteur est veniam.",
                 fromMe: true,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Officia commodo nostrud Lorem velit sunt. Fugiat reprehenderit laboris sint consequat eu. Dolor pariatur pariatur mollit consequat. Tempor eiusmod irure minim dolor nulla Lorem do occaecat et amet ipsum. Ex ipsum elit cillum Lorem. Dolor do nulla commodo elit sint aute.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
    
    Message.init(text: "Minim minim consectetur aute ipsum ea ullamco aliquip. Velit nisi fugiat officia labore tempor excepteur proident sint eiusmod. Irure proident quis esse cillum do sit ad in irure nostrud fugiat sunt voluptate. Culpa laboris non fugiat reprehenderit fugiat laboris laboris irure commodo. Lorem minim mollit nostrud sint quis culpa in sunt Lorem minim.",
                 fromMe: false,
                 attachements: 1,
                 date: Date.randomDate()),
]
