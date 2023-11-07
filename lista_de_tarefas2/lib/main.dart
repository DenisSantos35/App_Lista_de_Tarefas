import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //Criar uma lista para armazenamento de tarefas
  List _toDoList = [];

  //aqui criaremos um mapeamento para ver qual a ultima posicao e quem foi removido
  //para ao desfazer a tarefa cnseguir retornar para o local que foi removido
  late Map<String, dynamic> _lastRemove;
  late int _lastRomovePos;
  //Para nos ler o novo estado da lista toda vez que inicializamos
  //precisamos modificar um metodo chamado initState()
  //precisamos chamar nosso initState na super classe
  @override
  void initState() {
    super.initState(); //chamando metodo na super classe
    //agora sim podemos chamar nosso metodo de leitura
    //porem ele retorna algo no futuro vamos usar o then
    //o then vira com um parametro dentro no caso data que recebera o valor lido
    //ou seja a nossa lista, apartir dai decodificamos o resultado obtido em data
    // que -é json, modificando para dart e atribuindo a lista.
    //observando que a lista sempre iniciara vazia, assim vamos ao inicializar abri a pasta
    //e recolocar dentro da lista
    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });

    });

  }

  //controlador captura os valores da textFild e armazena na variavel
  final _toDoControler = TextEditingController();

  //funcao para adicionar os valores capturados na lista
  void _addToDo(){
    //criamos o modelo de mapa a ser adionado a _toDoList
    //Cria se um Map vasio, como vamos converter para jason este map
    //precisa ser String, dynamic e recebe o map vasio
   setState(() {
     Map<String, dynamic> newTodo = Map();
     //adicionar dentro do Map ainda em arquivo dart
     newTodo['title'] = _toDoControler.text;
     _toDoControler.text = ""; //zeramos o textField apagando
     newTodo['ok'] = false; // e retornamos o campo de seleção com false
     //apos criado adicionamos o Map na lista _toDoList()
     _toDoList.add(newTodo);
     //Ao salvar na lista eu atualizo minha pasta do diretorio json
     _saveData();
   });
  }

  //vamos agora fazer uma funcao que ao arrastar a tela para baixo ordenara nossos
  //itens em ok true e ok false
  Future<Null> _refresh() async{
    //vamos fazer com que ela demore um segundo assim temos
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      //essa ordenacao passamos uma funcao de comparação atraves do sort
      //recebera 2 valores a serem comparados
      _toDoList.sort((obj1, obj2){
        if(obj1["ok"] && !obj2["ok"]){
          return 1;
        }else if(!obj1["ok"] && obj2["ok"]){
          return -1;
        }else{
          return 0;
        }
      });
      _saveData();
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Lista de Tarefas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 35,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.black54, Colors.white10, Colors.black54]
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.black54, Colors.white10, Colors.black54]
                  ),
                ),
                padding: EdgeInsets.fromLTRB(17, 17, 17, 17),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _toDoControler,
                        decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _addToDo,
                      child: Text(
                        'ADD',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                //cria uma lista que nao consome recursos caso item nao apreca
                //parametros padding no topo para nao deixar a lista colada
                //tipo de lista que gra dinamicamente os campos
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    //pega o tamanho da lista como vai ser dinamica pega
                    //o tamanho da lista ao qual estamos armazenando assim se a lista aulmenta
                    //automaticamente aumenta.
                    itemCount: _toDoList.length,
                    //no item builder passamos o contexto a ser recebido e o index
                    itemBuilder: builderItem,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //para criacao de um widiget como funcao passamos o tipo Widget e o nome da funcao
  //este widget esta sendo chamando em itemBuild que por parametro recebe um contexto e um index
  //estamos retonando uma forma de slide de deslizamento feito pelo Dismisseble
  //a Key do dismissible e uma chave gerada para ele saber qua itme estamos pegando
  //no caso passamos o tempo atual em milissegundos para gerar uma chave aleatorio no tempo
  //o background esta recebendo um conteiner ou seja esta montando o retangulo ao ser deslizado
  //este container esta recebendo como filho um align que e um alinhamento
  //e tambem dentro do container estamos atribuindo um filho icon
  Widget builderItem(BuildContext context,int index){ //este contex, e index nao foram definidos
                                      //porem como foi chamado do builItem ele ja sabe os valores
                                      //que esta pengando no caso
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          //temos como parametro= Alignment(x = 0 sendo centro -1 esquera e 1 direita)
          //                                (y = 0 centro, -1 acima e 1 abaixo)
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      //mostra a forma como vai ser deslizado nosso dismissible
      // pode receber parametro startToEnd ou endToStart
      //ou seja da esquerda para direita ou da direita para esquerda
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        //aqui toda vez que clicamos no check box onChenged e chamado e
        //inverte o estado de checkBox passando para true or false.
        onChanged: (value){ //sempre recebe um valor por parametro
          setState(() {
            _toDoList[index]["ok"] = value;
            //ao atualizar o check box eu salvo o estado no meu diretório
            _saveData();
          });
        },
        title: Text(_toDoList[index]['title']),//_toDoList[0]['title'] = Denis
        value: _toDoList[index]['ok'],//_toDoList[0]['ok'] = True
        //cria um valor secundario dentro do checkbox ou seja um icone no inicio
        //e a iteracao do secundari esta na condição que passamos
        //caso o _todoList na posicao "ok" seja verdadeiro mostra um icon
        //caso seja falso mostra outro icon, assim se apertamos no check box
        //mudaremos a condiçao e alteraremos o icon
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]['ok'] ? Icons.check_circle : Icons.error_outlined),
        ),
      ),
      //cada vez que fazer um desmissible(destizar um widget) vamos chamar esta funcao
      //moditorando o que foi arrastado
      onDismissed: (direction){
        //vamos fazer uma copia do objeto que esta sendo deslizado para nosso novo metodo
        //e vamos salvar seu indice
        setState(() {
          _lastRemove = Map.from(_toDoList[index]!);
          _lastRomovePos = index;
          _toDoList.removeAt(index);
          _saveData();
        });
        //aqui vamos criar uma mensagem de alerta para o usuario
        //passamos um widget para uma variavel
        //colocamos em content a mensagem que queremos ver no alerta
        //colocamos em action uma funcao que ao apertar na label fara algo
          final snack = SnackBar(
            content: Text('Tarefa \"${_lastRemove["title"]} \" removida'),
            action: SnackBarAction(label: 'Desfazer',
                //esta funcao faz com que se voce apertar na mensagem desfazer
                //recolocara o item removido gravado copiado para lastRemove
                //e voltara para a posiçao ao qual ja estava gravado em lastRemovePos
                //e chamamos a funcao save data que tranforma em jason sava em data e escreve no arquivo
                onPressed: (){
                  setState(() {
                    _toDoList.insert(_lastRomovePos, _lastRemove);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 5),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }


  //@@@@@@@@@@comecar criando a parte de aabertura, salvamento e leitura
  //@@@@@@@@@@ criar dentro da classe

  //criar uma funcao que ira retornar o aqruivo que iremos salvar
  //sera responsavel por pegar os dados
  Future<File> _getFile() async {
    //agora vamos pegar o diretório onde estarão os documentos do meu app
    //armazenaremos na directory
    final directory = await getApplicationDocumentsDirectory();
    //retornara um arquivo(File)caminho do arquivo(directory.path)/nomedo arquivo(data).json
    return File("${directory.path}/data.json");
  }

  //Criar uma funcao para salvar os dados
  //tudo que ocorre leitura e escrita nao ocorre instantaneamente
  Future<File> _saveData() async {
    //primeiramente tranformar a lista _toDoList em jason
    String data = json.encode(_toDoList);
    //segundo pegar o nosso arquivo feito na funcao _getFile()
    final file = await _getFile();
    //terceiro escrever uma string dentro do arquivo armazenando nossa lista transformada em json
    return file.writeAsString(data);
  }

  //Função para obter dados
  //criamos uma funcao de leitura de dados
  Future<String> _readData() async{
    //para leitura utilizamos o try catch
    //tentamos obter um dado caso nao consiga retornará uma ecessão
    try{
      //para leitura pegamos nosso arquivo armazenando a no file através a funcao _getFile()
      final file = await _getFile();
      return file.readAsString();
    }catch(e){
      return "";
    }
  }

}
