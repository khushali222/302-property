import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class residential extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: (){},
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'SQFT *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the square footage';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Bath',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the unit address';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Bed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of beds';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}



class commercial extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: (){},
            ),
            SizedBox(width: 10),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'SQft *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the unit';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}



class residentialMulti extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: (){},
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: Container(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Unit *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the unit';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: Container(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Unit Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the unit address';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



class CommercialMulti extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: (){},
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Unit *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the unit';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Unit Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the unit address';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}


