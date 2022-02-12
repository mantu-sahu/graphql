import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  final store = await initHiveForFlutter();
  runApp(MaterialApp(title: "GQL App", home: MyApp()));
}

class MyApp extends StatelessWidget {
  final HttpLink httpLink = HttpLink(
    'https://countries.trevorblades.com/',
  );

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        //we can pass store to hivestore. default is in memory
        cache: GraphQLCache(),
      ),
    );
    return GraphQLProvider(
      child: const HomePage(),
      client: client,
    );
  }
}

class HomePage extends StatelessWidget {
  final String query = r"""
                    query GetContinent($code : ID!){
                      continent(code:$code){
                        name
                        countries{
                          name
                          emoji
                          capital
                        }
                      }
                    }
                  """;

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GraphlQL Client'),
      ),

      // To make a query using the graphql_flutter package, we’ll use the Query widget.
      // Query widget has two properties passed to it: options and builder.
      // The option property is where the configuration of the query is passed to the Query widget.
      // The QueryOptions class exposes properties we use to set options for the Query widget.
      // The document property is used to set the query string or to pass in the query we want the Query widget to perform.
      // The builder property is a function. The function is called when the
      // Query widget makes an HTTP request to the GraphQL server endpoint.
      //The builder function is called by the Query widget with the data from
      //the query, a function that is used to refetch the data, and a function
      //that is used for pagination. This is used to fetch more data

      // The builder function returns widgets below the Query widget.
      // The result arg is an instance of the QueryResult.
      // The QueryResult has properties that we can use to know the state of
      // the query and the data returned by the Query widget.

      body: Query(
          options: QueryOptions(
            document: gql(query),
            variables: <String, dynamic>{"code": "AS"},
            // pollInterval: const Duration(seconds: 10),
          ),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (result.data == null) {
              return const Text("No Data Found !");
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Text(
                    result.data!['continent']['countries'][index]['emoji'],
                  ),
                  title: Text(
                    result.data!['continent']['countries'][index]['name'],
                  ),
                  subtitle: Text(
                    result.data!['continent']['countries'][index]['capital'],
                  ),
                );
              },
              itemCount: result.data!['continent']['countries'].length,
            );
          }),
    );
  }
}
