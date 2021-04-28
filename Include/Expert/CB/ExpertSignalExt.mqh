//protected:   bool               m_exitsignal;
//public:   void              SetExit(bool value)        { m_exitsignal=value;      }
//public:  bool              GetExit(void)               { return m_exitsignal; }
//public:  double            Direction(bool OnlyExit);
public:  double            DirectionX(void);
public:    void              SetDirectionX()         { m_direction=DirectionX(); }
//public:    void              SetDirection(bool OnlyExit)         { m_direction=Direction(OnlyExit); }
public:    double            GetDirection(void)         {return m_direction;}